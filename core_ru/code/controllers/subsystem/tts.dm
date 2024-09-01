/datum/config_entry/string/tts_http_url
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/tts_http_token
	protection = CONFIG_ENTRY_LOCKED|CONFIG_ENTRY_HIDDEN

/datum/config_entry/number/tts_max_concurrent_requests
	default = 4
	min_val = 1

/datum/config_entry/str_list/tts_voice_blacklist

#define SS_PRIORITY_TTS 153

/datum/preferences
	var/forced_voice
	var/tts_volume = 50
	var/tts_setting = TTS_SOUND_ENABLED

GLOBAL_LIST_INIT(tts_voices_men_whitelists, list(
	"papich",
	"bebey",
	"puchkow",
	"moriarti",
	"biden",
	"obama",
	"trump",
	"dbkn2",
	"xrenoid",
	"briman",
	"father_grigori",
	"vance",
	"barni",
	"squidward",
	"robert_maccready",
	"threedog",
	"jericho_fl3",
	"elder_lyons_fl3",
	"colin_moriarty_fl3",
	"romka",
	"boris_petrov_father_tb",
	"semen_baburin_tb",
	"tihonov_tb",
	"cicero",
	"sheogorath",
	"kodlakwhitemane",
	"khajiit",
	"emperor",
	"guard",
	"hagraven",
	"nord",
	"ulfric",
	"nazir",
	"lord_harkon",
	"geralt",
	"lambert",
	"kovir_nobleman",
	"zoltan_chivay",
	"ekko",
	"ziggs",
	"arthas",
	"rexxar",
	"voljin",
	"bandit",
	"sidorovich",
	"strelok",
	"soldier",
	"engineer",
	"heavy",
	"medic",
	"demoman",
	"sniper",
	"spy",
	"punisher",
	"mitch",
	"jackie",
	"oswald_forrest",
	"steve",
	"butch",
	"marcus",
	"sulik",
	"narrator_d3",
	"dude",
	"anduin",
	"garrosh",
	"uther_hs",
	"bralik",
	"horner",
	"tosh",
	"tychus",
	"amitkakkar",
	"eleazarfig",
	"lodgok",
	"phineasblack",
	"ranrak",
	"gladwinmoon",
	"ominisgaunt",
	"generic_goblin_c",
	"aesop_sharp",
	"abraham_ronen"
))

GLOBAL_LIST_INIT(tts_voices_woman_whitelists, list(
	"charlotte",
	"amina",
	"alyx",
	"moira_brown",
	"sarah_lyons_fl3",
	"karina_petrova_tb",
	"elenwen",
	"astrid",
	"maven",
	"female_commander",
	"serana",
	"glados",
	"cirilla",
	"cerys",
	"triss",
	"caitlyn",
	"tracer",
	"panam",
	"v_female",
	"judy",
	"maiko",
	"nancy_hartley",
	"good_thalya",
	"evil_thalya",
	"hanson",
	"ignatiaflootravel",
	"matildaweasley",
	"natsaionai",
	"poppysweeting",
	"dinah_hecat",
	"samantha_dale",
	"sirona_ryan"
))

SUBSYSTEM_DEF(tts)
	name = "Text To Speech"
	wait = 0.05 SECONDS
	init_order = 82
	priority = SS_PRIORITY_TTS
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	/// Queued HTTP requests that have yet to be sent. TTS requests are handled as lists rather than datums.
	var/datum/heap/queued_http_messages

	/// An associative list of mobs mapped to a list of their own /datum/tts_request_target
	var/list/queued_tts_messages = list()

	/// TTS audio files that are being processed on when to be played.
	var/list/current_processing_tts_messages = list()

	/// HTTP requests currently in progress but not being processed yet
	var/list/in_process_http_messages = list()

	/// HTTP requests that are being processed to see if they've been finished
	var/list/current_processing_http_messages = list()

	/// A list of available speakers, which are string identifiers of the TTS voices that can be used to generate TTS messages.
	var/list/available_speakers = list()

	/// Whether TTS is enabled or not
	var/tts_enabled = FALSE
	/// Whether the TTS engine supports pitch adjustment or not.
	var/pitch_enabled = FALSE

	/// TTS messages won't play if requests took longer than this duration of time.
	var/message_timeout = 1 MINUTES

	/// The max concurrent http requests that can be made at one time. Used to prevent 1 server from overloading the tts server
	var/max_concurrent_requests = 4

	/// Used to calculate the average time it takes for a tts message to be received from the http server
	/// For tts messages which time out, it won't keep tracking the tts message and will just assume that the message took
	/// 7 seconds (or whatever the value of message_timeout is) to receive back a response.
	var/average_tts_messages_time = 0

/datum/controller/subsystem/tts/vv_edit_var(var_name, var_value)
	// tts being enabled depends on whether it actually exists
	if(NAMEOF(src, tts_enabled) == var_name)
		return FALSE
	return ..()

/datum/controller/subsystem/tts/stat_entry(msg)
	msg = "Active:[length(in_process_http_messages)]|Standby:[length(queued_http_messages?.L)]|Avg:[average_tts_messages_time]"
	return ..()

/proc/cmp_word_length_asc(datum/tts_request/a, datum/tts_request/b)
	return length(b.message) - length(a.message)

/// Establishes (or re-establishes) a connection to the TTS server and updates the list of available speakers.
/// This is blocking, so be careful when calling.
/datum/controller/subsystem/tts/proc/establish_connection_to_tts()
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/speakers", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		stack_trace(response.error)
		return FALSE
	var/list/temp_speakers = json_decode(response.body)?["voices"]
	for(var/speaker in temp_speakers)
		available_speakers.Add(speaker["speakers"][1])
	tts_enabled = TRUE
	if(CONFIG_GET(str_list/tts_voice_blacklist))
		var/list/blacklisted_voices = CONFIG_GET(str_list/tts_voice_blacklist)
		log_config("Processing the TTS voice blacklist.")
		for(var/voice in blacklisted_voices)
			if(available_speakers.Find(voice))
				log_config("Removed speaker [voice] from the TTS voice pool per config.")
				available_speakers.Remove(voice)
	var/datum/http_request/request_pitch = new()
	request_pitch.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/pitch-available", "")
	request_pitch.begin_async()
	UNTIL(request_pitch.is_complete())
	pitch_enabled = TRUE
	var/datum/http_response/response_pitch = request_pitch.into_response()
	if(response_pitch.errored || response_pitch.status_code != 200)
		if(response_pitch.errored)
			stack_trace(response.error)
		pitch_enabled = FALSE
	rustg_file_write(json_encode(available_speakers), "data/cached_tts_voices.json")
	rustg_file_write("rustg HTTP requests can't write to folders that don't exist, so we need to make it exist.", "tmp/tts/init.txt")
	return TRUE

/datum/controller/subsystem/tts/Initialize()
	if(!CONFIG_GET(string/tts_http_url))
		return SS_INIT_NO_NEED

	queued_http_messages = new /datum/heap(GLOBAL_PROC_REF(cmp_word_length_asc))
	max_concurrent_requests = CONFIG_GET(number/tts_max_concurrent_requests)
	if(!establish_connection_to_tts())
		return SS_INIT_FAILURE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/proc/play_tts(target, list/listeners, sound/audio, sound/audio_blips, volume_offset = 0)
	var/turf/turf_source = get_turf(target)
	if(!turf_source)
		return

	for(var/mob/receiver in listeners[1])
		if(!elligible_mob(receiver))
			continue
		var/audio_to_use = (receiver.client.prefs.tts_setting == TTS_SOUND_BLIPS) ? audio_blips : audio
		playsound_client(receiver.client, audio_to_use, turf_source, (((receiver == target)? 60 : 85) + volume_offset) * (receiver.client.prefs.tts_volume / 100))

	for(var/mob/receiver in listeners[2])
		if(!elligible_mob(receiver))
			continue
		playsound_client(receiver.client, audio_blips, turf_source, (((receiver == target)? 60 : 85) + volume_offset) * (receiver.client.prefs.tts_volume / 100))

	//Radio
	for(var/mob/receiver in listeners[3])
		if(!elligible_mob(receiver))
			continue
		var/audio_to_use = (receiver.client.prefs.tts_setting == TTS_SOUND_BLIPS) ? audio_blips : audio
		playsound_client(receiver.client, audio_to_use, null, (((receiver == target)? 60 : 85) + volume_offset) * (receiver.client.prefs.tts_volume / 100) / 1.5)

	for(var/mob/receiver in listeners[4])
		if(!elligible_mob(receiver))
			continue
		playsound_client(receiver.client, audio_blips, null, (((receiver == target)? 60 : 85) + volume_offset) * (receiver.client.prefs.tts_volume / 100) / 1.5)

/datum/controller/subsystem/tts/proc/elligible_mob(mob/receiver)
	if(QDELING(receiver))
		return FALSE
	if(!receiver.client?.prefs)
		return FALSE
	if(receiver.client.prefs.tts_volume == 0 || (receiver.client.prefs.tts_setting == TTS_SOUND_OFF))
		return FALSE
	return TRUE

// Need to wait for all HTTP requests to complete here because of a rustg crash bug that causes crashes when dd restarts whilst HTTP requests are ongoing.
/datum/controller/subsystem/tts/Shutdown()
	tts_enabled = FALSE
	for(var/datum/tts_request/data in in_process_http_messages)
		var/datum/http_request/request = data.request
		var/datum/http_request/request_blips = data.request_blips
		UNTIL(request.is_complete() && request_blips.is_complete())

#define SHIFT_DATA_ARRAY(tts_message_queue, target, data) \
	popleft(##data); \
	if(length(##data) == 0) { \
		##tts_message_queue -= ##target; \
	};

#define TTS_ARBRITRARY_DELAY "arbritrary delay"

/datum/controller/subsystem/tts/fire(resumed)
	if(!tts_enabled)
		flags |= SS_NO_FIRE
		return

	if(!resumed)
		while(length(in_process_http_messages) < max_concurrent_requests && length(queued_http_messages.L) > 0)
			var/datum/tts_request/entry = queued_http_messages.pop()
			var/timeout = entry.start_time + message_timeout
			if(timeout < world.time)
				entry.timed_out = TRUE
				continue
			entry.start_requests()
			in_process_http_messages += entry
		current_processing_http_messages = in_process_http_messages.Copy()
		current_processing_tts_messages = queued_tts_messages.Copy()

	// For speed
	var/list/processing_messages = current_processing_http_messages
	while(processing_messages.len)
		var/datum/tts_request/current_request = processing_messages[processing_messages.len]
		processing_messages.len--
		if(!current_request.requests_completed())
			continue

		var/datum/http_response/response = current_request.get_primary_response()
		in_process_http_messages -= current_request
		average_tts_messages_time = MC_AVERAGE(average_tts_messages_time, world.time - current_request.start_time)
		var/identifier = current_request.identifier
		if(current_request.requests_errored())
			current_request.timed_out = TRUE
			continue
		current_request.audio_length = text2num(response.headers["audio-length"]) * 10
		if(!current_request.audio_length)
			current_request.audio_length = 0
		current_request.audio_file = "tmp/tts/[identifier].ogg"
		current_request.audio_file_blips = "tmp/tts/[identifier]_blips.ogg" // We aren't as concerned about the audio length for blips as we are with actual speech
		// Don't need the request anymore so we can deallocate it
		current_request.request = null
		current_request.request_blips = null
		if(MC_TICK_CHECK)
			break

	if(MC_TICK_CHECK)
		return

	var/list/processing_tts_messages = current_processing_tts_messages
	while(processing_tts_messages.len)
		if(MC_TICK_CHECK)
			break

		var/datum/tts_target = processing_tts_messages[processing_tts_messages.len]
		var/list/data = processing_tts_messages[tts_target]
		processing_tts_messages.len--
		if(QDELETED(tts_target))
			queued_tts_messages -= tts_target
			continue

		var/datum/tts_request/current_target = data[1]
		// This determines when we start the timer to time out.
		// This is so that the TTS message doesn't get timed out if it's waiting
		// on another TTS message to finish playing their audio.

		// For example, if a TTS message plays for more than 7 seconds, which is our current timeout limit,
		// then the next TTS message would be unable to play.
		var/timeout_start = current_target.when_to_play
		if(!timeout_start)
			// In the normal case, we just set timeout to start_time as it means we aren't waiting on
			// a TTS message to finish playing
			timeout_start = current_target.start_time

		var/timeout = timeout_start + message_timeout
		// Here, we check if the request has timed out or not.
		// If current_target.timed_out is set to TRUE, it means the request failed in some way
		// and there is no TTS audio file to play.
		if(timeout < world.time || current_target.timed_out)
			SHIFT_DATA_ARRAY(queued_tts_messages, tts_target, data)
			continue

		if(current_target.audio_file)
			if(current_target.audio_file == TTS_ARBRITRARY_DELAY)
				if(current_target.when_to_play < world.time)
					SHIFT_DATA_ARRAY(queued_tts_messages, tts_target, data)
				continue
			var/sound/audio_file
			var/sound/audio_file_blips
			if(current_target.local)
				if(current_target.use_blips)
					audio_file_blips = new(current_target.audio_file_blips)
					SEND_SOUND(current_target.target, audio_file_blips)
				else
					audio_file = new(current_target.audio_file)
					SEND_SOUND(current_target.target, audio_file)
				SHIFT_DATA_ARRAY(queued_tts_messages, tts_target, data)
			else if(current_target.when_to_play < world.time)
				audio_file = new(current_target.audio_file)
				audio_file_blips = new(current_target.audio_file_blips)
				play_tts(tts_target, current_target.listeners, audio_file, audio_file_blips, current_target.volume_offset)
				if(length(data) != 1)
					var/datum/tts_request/next_target = data[2]
					next_target.when_to_play = world.time + current_target.audio_length
				else
					// So that if the audio file is already playing whilst a new file comes in,
					// it won't play in the middle of the audio file.
					var/datum/tts_request/arbritrary_delay = new()
					arbritrary_delay.when_to_play = world.time + current_target.audio_length
					arbritrary_delay.audio_file = TTS_ARBRITRARY_DELAY
					queued_tts_messages[tts_target] += arbritrary_delay
				SHIFT_DATA_ARRAY(queued_tts_messages, tts_target, data)


#undef TTS_ARBRITRARY_DELAY

/datum/controller/subsystem/tts/proc/queue_tts_message(datum/target, message, speaker, list/listeners, local = FALSE, volume_offset = 0, pitch = 0, special_filters = "")
	if(!tts_enabled)
		return

	// TGS updates can clear out the tmp folder, so we need to create the folder again if it no longer exists.
	if(!fexists("tmp/tts/init.txt"))
		rustg_file_write("rustg HTTP requests can't write to folders that don't exist, so we need to make it exist.", "tmp/tts/init.txt")

	var/shell_scrubbed_input = message
	var/identifier = "[sha1(speaker + num2text(pitch) + special_filters + shell_scrubbed_input)].[world.time]"
	if(!(speaker in available_speakers))
		return

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	headers["Authorization"] = "Bearer [CONFIG_GET(string/tts_http_token)]"
	var/datum/http_request/request = new()
	var/datum/http_request/request_blips = new()
	var/file_name = "tmp/tts/[identifier].ogg"
	var/file_name_blips = "tmp/tts/[identifier]_blips.ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]?speaker=[speaker]&effect=[url_encode(special_filters)]&ext=ogg&text=[shell_scrubbed_input]", null, headers, file_name)
	request_blips.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]?speaker=[speaker]&effect=[url_encode(special_filters)]&ext=ogg&text=[shell_scrubbed_input]", null, headers, file_name_blips)
	var/datum/tts_request/current_request = new /datum/tts_request(identifier, request, request_blips, shell_scrubbed_input, target, local, volume_offset, listeners, pitch)
	var/list/player_queued_tts_messages = queued_tts_messages[target]
	if(!player_queued_tts_messages)
		player_queued_tts_messages = list()
		queued_tts_messages[target] = player_queued_tts_messages
	player_queued_tts_messages += current_request
	if(length(in_process_http_messages) < max_concurrent_requests)
		current_request.start_requests()
		in_process_http_messages += current_request
	else
		queued_http_messages.insert(current_request)

/// A struct containing information on an individual player or mob who has made a TTS request
/datum/tts_request
	/// The mob to play this TTS message on
	var/mob/target
	/// The people who are going to hear this TTS message
	/// Does nothing if local is set to TRUE
	var/list/listeners
	/// The HTTP request of this message
	var/datum/http_request/request
	/// The HTTP request of this message for blips
	var/datum/http_request/request_blips
	/// The message itself
	var/message
	/// The message identifier
	var/identifier
	/// The volume offset to play this TTS at.
	var/volume_offset = 0
	/// Whether this TTS message should be sent to the target only or not.
	var/local = FALSE
	/// The time at which this request was started
	var/start_time

	/// The audio file of this tts request.
	var/sound/audio_file
	/// The blips audio file of this tts request.
	var/sound/audio_file_blips
	/// The audio length of this tts request.
	var/audio_length
	/// When the audio file should play at the minimum
	var/when_to_play = 0
	/// Whether this request was timed out or not
	var/timed_out = FALSE
	/// Does this use blips during local generation or not?
	var/use_blips = FALSE
	/// What's the pitch adjustment?
	var/pitch = 0

BSQL_PROTECT_DATUM(/datum/tts_request)

/datum/tts_request/New(identifier, datum/http_request/request, datum/http_request/request_blips, message, target, local, volume_offset, list/listeners, pitch)
	. = ..()
	src.identifier = identifier
	src.request = request
	src.request_blips = request_blips
	src.message = message
	src.target = target
	src.local = local
	src.volume_offset = volume_offset
	src.listeners = listeners
	src.pitch = pitch
	start_time = world.time

/datum/tts_request/proc/start_requests()
	if(istype(target, /client))
		var/client/current_client = target
		use_blips = (current_client?.prefs.tts_setting == TTS_SOUND_BLIPS)
	else if(istype(target, /mob))
		use_blips = (target.client?.prefs.tts_setting == TTS_SOUND_BLIPS)
	if(local)
		if(use_blips)
			request_blips.begin_async()
		else
			request.begin_async()
	else
		request.begin_async()
		request_blips.begin_async()

/datum/tts_request/proc/get_primary_request()
	if(local)
		if(use_blips)
			return request_blips
		else
			return request
	else
		return request

/datum/tts_request/proc/get_primary_response()
	if(local)
		if(use_blips)
			return request_blips.into_response()
		else
			return request.into_response()
	else
		return request.into_response()

/datum/tts_request/proc/requests_errored()
	if(local)
		var/datum/http_response/response
		if(use_blips)
			response = request_blips.into_response()
		else
			response = request.into_response()
		return response.errored
	else
		var/datum/http_response/response = request.into_response()
		var/datum/http_response/response_blips = request_blips.into_response()
		return response.errored || response_blips.errored

/datum/tts_request/proc/requests_completed()
	if(local)
		if(use_blips)
			return request_blips.is_complete()
		else
			return request.is_complete()
	else
		return request.is_complete() && request_blips.is_complete()

#undef SHIFT_DATA_ARRAY


//////////////////////
//datum/heap object
//////////////////////

/datum/heap
	var/list/L
	var/cmp

/datum/heap/New(compare)
	L = new()
	cmp = compare

/datum/heap/Destroy(force, ...)
	for(var/i in L) // because this is before the list helpers are loaded
		qdel(i)
	L = null
	return ..()

/datum/heap/proc/is_empty()
	return !length(L)

//insert and place at its position a new node in the heap
/datum/heap/proc/insert(A)

	L.Add(A)
	swim(length(L))

//removes and returns the first element of the heap
//(i.e the max or the min dependant on the comparison function)
/datum/heap/proc/pop()
	if(!length(L))
		return 0
	. = L[1]

	L[1] = L[length(L)]
	L.Cut(length(L))
	if(length(L))
		sink(1)

//Get a node up to its right position in the heap
/datum/heap/proc/swim(index)
	var/parent = round(index * 0.5)

	while(parent > 0 && (call(cmp)(L[index],L[parent]) > 0))
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)

//Get a node down to its right position in the heap
/datum/heap/proc/sink(index)
	var/g_child = get_greater_child(index)

	while(g_child > 0 && (call(cmp)(L[index],L[g_child]) < 0))
		L.Swap(index,g_child)
		index = g_child
		g_child = get_greater_child(index)

//Returns the greater (relative to the comparison proc) of a node children
//or 0 if there's no child
/datum/heap/proc/get_greater_child(index)
	if(index * 2 > length(L))
		return 0

	if(index * 2 + 1 > length(L))
		return index * 2

	if(call(cmp)(L[index * 2],L[index * 2 + 1]) < 0)
		return index * 2 + 1
	else
		return index * 2

//Replaces a given node so it verify the heap condition
/datum/heap/proc/resort(A)
	var/index = L.Find(A)

	swim(index)
	sink(index)

/datum/heap/proc/List()
	. = L.Copy()

/mob
	var/tts_voice
