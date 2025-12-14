export interface User {
  id: string;
  name: string;
  avatar?: string;
}

export interface Session {
  id: string;
  title: string;
  location: string;
  date: string;
  thumbnail?: string;
}

export interface Video {
  id: string;
  title: string;
  location: string;
  date: string;
  thumbnail?: string;
  duration?: string;
}

export interface SwingVideo {
  id: string;
  title: string;
  type: string;
  date: string;
  description: string;
  thumbnail?: string;
}

export interface RoundStats {
  greensInRegulation: number;
  fairwaysHit: number;
  avgPuttsPerRound: number;
  scoringAverage: number;
}

export interface RoundHistory {
  id: string;
  course: string;
  date: string;
  score: number;
}

export interface PlayOfTheWeek {
  id: string;
  playerName: string;
  playerTitle: string;
  location: string;
  thumbnail?: string;
  avatar?: string;
}

export interface QuickAction {
  id: string;
  title: string;
  subtitle: string;
  icon: string;
}
