// index.d.ts - TypeScript definitions for libmpvnative
// OpenGL-based MPV video player for HarmonyOS

/**
 * Create a new MPV instance configured for OpenGL rendering
 * @returns MPV handle as number, or null if creation failed
 */
export const create: () => number | null;

/**
 * Initialize the rendering surface with the given surface ID
 * @param surfaceId - XComponent surface identifier
 */
export const initSurface: (surfaceId: string) => void;

/**
 * Setup OpenGL rendering context for MPV
 * @param mpvHandle - MPV instance handle returned by create()
 */
export const setupGL: (mpvHandle: number) => void;

/**
 * Load and start playing a video
 * @param mpvHandle - MPV instance handle
 * @param url - Video URL to play (supports HTTP, HTTPS, file:// etc.)
 */
export const loadVideo: (mpvHandle: number, url: string) => void;

/**
 * Destroy OpenGL resources and cleanup rendering context
 * Call this when the component is being destroyed
 */
export const destroyGL: () => void;

/**
 * Destroy the MPV instance and stop all playback
 * @param mpvHandle - MPV instance handle to destroy
 */
export const destroy: (mpvHandle: number) => void;