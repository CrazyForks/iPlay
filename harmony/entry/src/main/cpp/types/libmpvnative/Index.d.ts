// index.d.ts
export const GetMpvApiVersion: () => number;
export const MpvCreate: () => number;
export const LoadVideo: (mpv: number, url: string) => void;
