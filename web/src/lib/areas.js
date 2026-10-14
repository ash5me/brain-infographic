// Map geometry for each area, in the same 680 x 400 SVG space as regions.js.
// Order must match `Area` in zig/gaps.zig.
//
// view.shapes: ellipses to draw
//   deep:    structure lies below the surface, drawn with a dotted outline
//   outside: drawn outside the cortex outline (cerebellum, brainstem, olfactory bulb)
// view.labels: text shown when the area is selected or hovered

export const AREAS = [
  {
    id: 'hippocampus',
    lateral: {
      shapes: [{ cx: 385, cy: 268, rx: 52, ry: 9, rotate: -12, deep: true }],
      labels: [{ text: 'Hippocampus', x: 385, y: 290 }],
    },
    medial: {
      shapes: [{ cx: 385, cy: 262, rx: 52, ry: 9, rotate: -12 }],
      labels: [{ text: 'Hippocampus', x: 390, y: 284 }],
    },
  },
  {
    id: 'amygdala',
    lateral: {
      shapes: [{ cx: 332, cy: 278, rx: 13, ry: 11, deep: true }],
      labels: [{ text: 'Amygdala', x: 292, y: 288 }],
    },
    medial: {
      shapes: [
        { cx: 332, cy: 272, rx: 14, ry: 12 },
        { cx: 352, cy: 238, rx: 13, ry: 8 },
      ],
      labels: [
        { text: 'Amygdala', x: 290, y: 276 },
        { text: 'Hypothalamus', x: 410, y: 238 },
      ],
    },
  },
  {
    id: 'cingulate-insula',
    lateral: {
      shapes: [{ cx: 325, cy: 228, rx: 38, ry: 13, rotate: -6, deep: true }],
      labels: [{ text: 'Insula', x: 325, y: 208 }],
    },
    medial: {
      shapes: [{ cx: 250, cy: 142, rx: 38, ry: 10, rotate: -18 }],
      labels: [{ text: 'Anterior cingulate', x: 250, y: 118 }],
    },
  },
  {
    id: 'basal-ganglia',
    lateral: {
      shapes: [{ cx: 330, cy: 185, rx: 36, ry: 20, deep: true }],
      labels: [{ text: 'Basal ganglia', x: 330, y: 160 }],
    },
    medial: {
      shapes: [
        { cx: 308, cy: 203, rx: 32, ry: 22 },
        { cx: 348, cy: 218, rx: 14, ry: 10 },
      ],
      labels: [{ text: 'Basal ganglia', x: 300, y: 176 }],
    },
  },
  {
    id: 'somatosensory',
    lateral: {
      shapes: [{ cx: 332, cy: 122, rx: 20, ry: 58, rotate: 12 }],
      labels: [{ text: 'Somatosensory', x: 336, y: 122 }],
    },
    medial: {
      shapes: [{ cx: 335, cy: 92, rx: 18, ry: 13 }],
      labels: [{ text: 'Somatosensory', x: 335, y: 70 }],
    },
  },
  {
    id: 'social',
    lateral: {
      shapes: [{ cx: 445, cy: 190, rx: 30, ry: 24 }],
      labels: [{ text: 'Temporoparietal junction', x: 445, y: 160 }],
    },
    medial: {
      shapes: [{ cx: 195, cy: 140, rx: 30, ry: 42 }],
      labels: [{ text: 'Medial prefrontal', x: 205, y: 106 }],
    },
  },
  {
    id: 'orbitofrontal',
    lateral: null,
    medial: {
      shapes: [{ cx: 215, cy: 248, rx: 42, ry: 13, rotate: 8 }],
      labels: [{ text: 'Orbitofrontal cortex', x: 222, y: 270 }],
    },
  },
  {
    id: 'smell-taste',
    lateral: {
      shapes: [{ cx: 262, cy: 226, rx: 20, ry: 10 }],
      labels: [{ text: 'Gustatory (taste)', x: 250, y: 206 }],
    },
    medial: {
      shapes: [{ cx: 168, cy: 298, rx: 26, ry: 7, rotate: 25, outside: true }],
      labels: [{ text: 'Olfactory bulb', x: 140, y: 322 }],
    },
  },
  {
    id: 'vestibular',
    lateral: {
      shapes: [
        { cx: 385, cy: 225, rx: 22, ry: 12 },
        { cx: 500, cy: 308, rx: 62, ry: 26, outside: true },
      ],
      labels: [
        { text: 'Vestibular cortex', x: 385, y: 247 },
        { text: 'Cerebellum', x: 500, y: 310 },
      ],
    },
    medial: {
      shapes: [
        { cx: 413, cy: 338, rx: 10, ry: 14, outside: true },
        { cx: 500, cy: 308, rx: 62, ry: 26, outside: true },
      ],
      labels: [
        { text: 'Vestibular nuclei', x: 413, y: 388 },
        { text: 'Cerebellum', x: 500, y: 310 },
      ],
    },
  },
];

export const CALLOSUM_PATH = 'M205 178 C245 140 410 130 470 175';
