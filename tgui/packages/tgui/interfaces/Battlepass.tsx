import { BooleanLike, classes } from 'common/react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

interface BattlepassReward {
  name: string;
  icon_state: string;
  tier: number;
  lifeform_type: string;
}

interface BattlepassChallenge {
  name: string;
  desc: string;
  completed: BooleanLike;
  category: string;
  completion_xp: number;
  completion_percent: number;
  completion_numerator: number;
  completion_denominator: number;
}

interface BattlepassData {
  season: string;
  xp: number;
  tier: number;
  max_tier: number;
  xp_tierup: number;
  rewards: BattlepassReward[];
  premium_rewards: BattlepassReward[];
  daily_challenges: BattlepassChallenge[];
}

export const Battlepass = (props) => {
  return (
    <Window width={1850} height={610} theme="usmc" title="Battlepass">
      <Window.Content>
        <BattlepassContent />
      </Window.Content>
    </Window>
  );
};

const BattlepassContent = (props) => {
  const { act, data } = useBackend<BattlepassData>();
  const rewards = data.rewards;
  const premium_rewards = data.premium_rewards;
  const [infoView, setInfoView] = useLocalState('info_view', false);
  return (
    <>
      {infoView === true ? (
        <Dimmer>
          <Box
            style={{
              width: '800px',
              height: '460px',
              display: 'flex',
              backgroundColor: '#0c0e1e',
              fontFamily: 'Verdana, Geneva, sans-serif',
              textAlign: 'center',
              justifyContent: 'center',
              alignItems: 'center',
              fontSize: '18px',
              padding: '10px',
            }}
          >
            <Section
              title="Battlepass"
              style={{
                width: '100%',
                height: '100%',
              }}
            >
              The battlepass system is a way of rewarding players with in-game
              rewards for playing well.
              <Box style={{ height: '10px' }} />
              <Box style={{ height: '10px' }} />
              On the left of the UI, you can find your objectives. These
              objectives are unique to you and reset every 24 hours. Completing
              them gives you XP. The other way to obtain XP is by playing a
              match to completion. Everyone gets XP regardless of winning or
              losing, but the winning side earns more. Whichever side you join
              first will be the side you gain XP for, even if you log out before
              the round ends.
              <Box style={{ height: '10px' }} />
              <Box style={{ height: '10px' }} />
              Every 10 XP, your battlepass tier increases by 1, granting you new
              rewards to use in game. You can claim rewards with the &quot;Claim
              Battlepass Reward&quot; verb, and come back to this UI with the
              &quot;Battlepass&quot; verb.
              <Box style={{ height: '10px' }} />
              <Box style={{ height: '10px' }} />
              The premium battlepass is coming soon, purchasable for an
              also-coming-soon 1000 ColonialCoins.
              <Box style={{ height: '10px' }} />
              <Box style={{ height: '10px' }} />
              <Button
                fontSize="16px"
                icon="xmark"
                content="Exit"
                onClick={() => {
                  setInfoView(false);
                }}
              />
            </Section>
          </Box>
        </Dimmer>
      ) : (
        <> </>
      )}
      <Box
        style={{
          display: 'flex',
          overflow: 'auto',
        }}
      >
        <BattlepassInfoContainer />
        <Box
          style={{
            overflowX: 'auto',
            display: 'flex',
            flexWrap: 'wrap',
            position: 'relative',
            maxWidth: '1500px',
            minWidth: '1500px',
          }}
        >
          <Box
            style={{
              position: 'absolute',
              top: '32%',
              left: '35%',
              fontSize: '24px',
              fontFamily: 'Verdana, Geneva, sans-serif',
              zIndex: `${infoView === true ? '0' : '10'}`,
            }}
          >
            Premium Battlepass coming soon!
          </Box>
          <Box
            style={{
              position: 'absolute',
              top: '84%',
              left: '35%',
              fontSize: '24px',
              fontFamily: 'Verdana, Geneva, sans-serif',
              zIndex: `${infoView === true ? '0' : '10'}`,
            }}
          >
            Premium Battlepass coming soon!
          </Box>
          {rewards.map((reward, rewardIndex) => (
            <BattlepassRegularEntry
              key={reward.tier}
              reward={reward}
              premiumReward={premium_rewards[rewardIndex]}
            />
          ))}
        </Box>
      </Box>
    </>
  );
};

const BattlepassInfoContainer = (props) => {
  const { act, data } = useBackend<BattlepassData>();
  const [infoView, setInfoView] = useLocalState('info_view', false);
  return (
    <Box
      style={{
        paddingRight: '20px',
        borderRight: 'solid',
      }}
    >
      <Section title={data.season}>
        <Button
          fontSize="12px"
          icon="circle-info"
          content="Information"
          onClick={() => {
            setInfoView(true);
          }}
        />
        <Box style={{ height: '10px' }} />
        <Box style={{ fontWeight: 'bold', fontSize: '16px' }}>
          Tier: {data.tier} / {data.max_tier}
          <Box style={{ height: '10px' }} />
          XP: {data.xp} / 10
        </Box>
        {data.daily_challenges.map((challenge) => (
          <BattlepassChallengeUI challenge={challenge} key={challenge.name} />
        ))}
      </Section>
    </Box>
  );
};

const BattlepassChallengeUI = (props) => {
  const challenge: BattlepassChallenge = props.challenge;
  return (
    <Section title={`${challenge.category} - ${challenge.name}`}>
      {challenge.desc}
      <Box
        style={{
          paddingBottom: '4px',
        }}
      />
      <ProgressBar
        minValue={0}
        maxValue={1}
        value={challenge.completion_percent}
        ranges={{
          bad: [0, 0.4],
          average: [0.4, 0.7],
          good: [0.7, 1],
        }}
      >
        Completion: {challenge.completion_numerator} /{' '}
        {challenge.completion_denominator}
      </ProgressBar>
      Reward: {challenge.completion_xp} XP
    </Section>
  );
};

const BattlepassRegularEntry = (props) => {
  const { act, data } = useBackend<BattlepassData>();
  const reward: BattlepassReward = props.reward;
  const premiumReward: BattlepassReward = props.premiumReward;
  return (
    <Box
      style={{
        borderStyle: 'none',
        borderWidth: '2px',
        borderColor: 'black',
        marginRight: '10px',
        width: '135px',
      }}
    >
      {data.tier >= reward.tier ? (
        <Box
          style={{
            backgroundColor: 'rgba(0, 255, 0, 0.4)',
            width: '100%',
            paddingTop: '3px',
            paddingBottom: '3px',
            textAlign: 'center',
          }}
        >
          {reward.name}
        </Box>
      ) : (
        <Box
          style={{
            backgroundColor: 'rgba(255, 0, 0, 0.4)',
            width: '100%',
            paddingTop: '3px',
            paddingBottom: '3px',
            textAlign: 'center',
          }}
        >
          {reward.name}
        </Box>
      )}
      <Box
        style={{
          backgroundImage: 'linear-gradient(black, transparent)',
        }}
      >
        <Box
          style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
          }}
        >
          <Box
            style={{ display: 'inline', fontWeight: 'bold' }}
            className={classes(['battlepass96x96', `${reward.icon_state}`])}
          />
        </Box>
        <Box
          style={{
            textAlign: 'center',
          }}
        >
          ({reward.lifeform_type})
        </Box>
      </Box>
      {data.tier >= reward.tier ? (
        <Box
          style={{
            backgroundImage:
              'linear-gradient(rgba(0, 255, 0, 0.4), rgba(212, 68, 23, 0.4))',
            width: '100%',
            paddingTop: '3px',
            paddingBottom: '3px',
            textAlign: 'center',
          }}
        >
          {reward.tier}
        </Box>
      ) : (
        <Box
          style={{
            backgroundImage:
              'linear-gradient(rgba(255, 0, 0, 0.4), rgba(212, 68, 23, 0.4))',
            width: '100%',
            paddingTop: '3px',
            paddingBottom: '3px',
            textAlign: 'center',
          }}
        >
          {reward.tier}
        </Box>
      )}
      <Box
        style={{
          opacity: '0.5',
        }}
      >
        <Box
          style={{
            backgroundImage: 'linear-gradient(black, transparent)',
          }}
        >
          <Box
            style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            <Box
              style={{ display: 'inline', fontWeight: 'bold' }}
              className={classes([
                'battlepass96x96',
                `${premiumReward.icon_state}`,
              ])}
            />
          </Box>
          <Box
            style={{
              textAlign: 'center',
            }}
          >
            ({premiumReward.lifeform_type})
          </Box>
        </Box>
        <Box
          style={{
            backgroundColor: 'rgba(212, 68, 23, 0.4)',
            width: '100%',
            paddingTop: '3px',
            paddingBottom: '3px',
            textAlign: 'center',
          }}
        >
          {premiumReward.name}
        </Box>
      </Box>
    </Box>
  );
};
