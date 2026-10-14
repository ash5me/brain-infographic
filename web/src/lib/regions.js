// Column order must match `Region` in zig/brain.zig.
// Geometry is in the 680 x 400 SVG coordinate space used by Brain.svelte.
export const REGIONS = [
  { id: 'pf', name: 'Prefrontal cortex', short: 'Prefrontal', cx: 180, cy: 155, rx: 58, ry: 68, label: [180, 130] },
  { id: 'mo', name: 'Motor cortex', short: 'Motor', cx: 300, cy: 120, rx: 24, ry: 62, rotate: 12, label: [300, 120] },
  { id: 'pa', name: 'Parietal lobe', short: 'Parietal', cx: 405, cy: 120, rx: 55, ry: 55, label: [405, 120] },
  { id: 'oc', name: 'Occipital lobe', short: 'Occipital', cx: 545, cy: 185, rx: 48, ry: 70, label: [540, 185] },
  { id: 'tp', name: 'Temporal lobe', short: 'Temporal', cx: 300, cy: 266, rx: 105, ry: 28, label: [245, 272] },
  { id: 'au', name: 'Auditory cortex', short: 'Auditory', cx: 340, cy: 246, rx: 30, ry: 12, label: [340, 246] },
  { id: 'br', name: "Broca's area", short: 'Broca', cx: 222, cy: 228, rx: 26, ry: 17, label: [222, 228] },
  { id: 'we', name: "Wernicke's area", short: 'Wernicke', cx: 425, cy: 222, rx: 32, ry: 16, label: [425, 222] },
  { id: 'cb', name: 'Cerebellum', short: 'Cerebellum', cx: 500, cy: 308, rx: 62, ry: 26, label: [500, 310], outside: true },
];

export const BRAIN_PATH =
  'M120 230 C105 160 160 80 260 65 C350 48 460 55 525 100 C585 145 595 220 560 262 C545 280 520 285 500 282 C470 280 450 290 420 300 C390 312 350 305 320 298 C290 292 250 305 215 295 C170 285 130 270 120 230 Z';

export const SULCI = [
  'M318 62 C305 100 300 140 292 185',
  'M225 247 C290 240 360 230 440 210',
  'M485 100 C498 140 494 180 482 215',
];
