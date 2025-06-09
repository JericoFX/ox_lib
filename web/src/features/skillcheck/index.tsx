import { useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import Indicator from './indicator';
import { fetchNui } from '../../utils/fetchNui';
import { Box, createStyles } from '@mantine/core';
import type { GameDifficulty, SkillCheckProps } from '../../typings';

export const circleCircumference = 2 * 50 * Math.PI;

const getRandomAngle = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min;

const difficultyOffsets = {
  easy: 50,
  medium: 40,
  hard: 25,
};

const useStyles = createStyles((theme, params: { difficultyOffset: number }) => ({
  svg: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    r: 50,
    width: 500,
    height: 500,
  },
  track: {
    fill: 'transparent',
    stroke: 'rgba(59, 130, 246, 0.1)',
    strokeWidth: 6,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    '@media (min-height: 1440px)': {
      strokeWidth: 8,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
    },
  },
  skillArea: {
    fill: 'transparent',
    stroke: '#e2e8f0',
    strokeWidth: 6,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - (Math.PI * 50 * params.difficultyOffset) / 180,
    filter: 'drop-shadow(0 0 4px rgba(226, 232, 240, 0.3))',
    '@media (min-height: 1440px)': {
      strokeWidth: 8,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
      strokeDashoffset: 2 * 65 * Math.PI - (Math.PI * 65 * params.difficultyOffset) / 180,
    },
  },
  indicator: {
    stroke: '#3b82f6',
    strokeWidth: 12,
    fill: 'transparent',
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - 3,
    filter: 'drop-shadow(0 0 6px rgba(59, 130, 246, 0.4))',
    '@media (min-height: 1440px)': {
      strokeWidth: 14,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
      strokeDashoffset: 2 * 65 * Math.PI - 5,
    },
  },
  button: {
    position: 'absolute',
    left: '50%',
    top: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    color: '#e2e8f0',
    border: '1px solid rgba(59, 130, 246, 0.2)',
    width: 25,
    height: 25,
    textAlign: 'center',
    borderRadius: 0,
    fontSize: 14,
    fontWeight: 500,
    fontFamily: 'Roboto',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    letterSpacing: '0.02em',
    boxShadow: '0 0 8px rgba(59, 130, 246, 0.2)',
    '@media (min-height: 1440px)': {
      width: 30,
      height: 30,
      fontSize: 18,
    },
  },
}));

const SkillCheck: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const dataRef = useRef<{ difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] } | null>(null);
  const dataIndexRef = useRef<number>(0);
  const [skillCheck, setSkillCheck] = useState<SkillCheckProps>({
    angle: 0,
    difficultyOffset: 50,
    difficulty: 'easy',
    key: 'e',
  });
  const { classes } = useStyles({ difficultyOffset: skillCheck.difficultyOffset });

  useNuiEvent('startSkillCheck', (data: { difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] }) => {
    dataRef.current = data;
    dataIndexRef.current = 0;
    const gameData = Array.isArray(data.difficulty) ? data.difficulty[0] : data.difficulty;
    const offset = typeof gameData === 'object' ? gameData.areaSize : difficultyOffsets[gameData];
    const randomKey = data.inputs ? data.inputs[Math.floor(Math.random() * data.inputs.length)] : 'e';
    setSkillCheck({
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: gameData,
      keys: data.inputs?.map((input) => input.toLowerCase()),
      key: randomKey.toLowerCase(),
    });

    setVisible(true);
  });

  useNuiEvent('skillCheckCancel', () => {
    setVisible(false);
    fetchNui('skillCheckOver', false);
  });

  const handleComplete = (success: boolean) => {
    if (!dataRef.current) return;
    if (!success || !Array.isArray(dataRef.current.difficulty)) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    if (dataIndexRef.current >= dataRef.current.difficulty.length - 1) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    dataIndexRef.current++;
    const data = dataRef.current.difficulty[dataIndexRef.current];
    const key = dataRef.current.inputs
      ? dataRef.current.inputs[Math.floor(Math.random() * dataRef.current.inputs.length)]
      : 'e';
    const offset = typeof data === 'object' ? data.areaSize : difficultyOffsets[data];
    setSkillCheck((prev) => ({
      ...prev,
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: data,
      key: key.toLowerCase(),
    }));
  };

  return (
    <>
      {visible && (
        <>
          <svg className={classes.svg}>
            {/*Circle track*/}
            <circle className={classes.track} />
            {/*SkillCheck area*/}
            <circle transform={`rotate(${skillCheck.angle}, 250, 250)`} className={classes.skillArea} />
            <Indicator
              angle={skillCheck.angle}
              offset={skillCheck.difficultyOffset}
              multiplier={
                skillCheck.difficulty === 'easy'
                  ? 1
                  : skillCheck.difficulty === 'medium'
                  ? 1.5
                  : skillCheck.difficulty === 'hard'
                  ? 1.75
                  : skillCheck.difficulty.speedMultiplier
              }
              handleComplete={handleComplete}
              className={classes.indicator}
              skillCheck={skillCheck}
            />
          </svg>
          <Box className={classes.button}>{skillCheck.key.toUpperCase()}</Box>
        </>
      )}
    </>
  );
};

export default SkillCheck;
