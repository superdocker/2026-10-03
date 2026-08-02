# Image optimization rules

The whole page is capped at `max-width: 480px` (see `body` in `index.html`), so no
image on this site ever needs to be larger than roughly 3x that width (~1440px)
even on a retina phone. Photos dropped in straight from a phone/camera are
typically 3000-4600px on the long edge and 4-6MB each — 5-10x oversized. Always
resize/compress before committing new photos.

Requires ImageMagick (`brew install imagemagick`) — check with `magick -version`.

## Gallery photos (`gallery/`)

The gallery grid shows small thumbnails (CSS height 300px) that open into a
lightbox (92vw wide, max 78vh tall). Two versions are generated per photo:

- **Full size** (`gallery/image_N.jpeg`) — used by the lightbox.
- **Thumbnail** (`gallery/thumbs/image_N.jpeg`) — used by the grid.

```bash
cd gallery
mkdir -p thumbs
for f in image_*.jpeg; do
  magick "$f" -auto-orient -resize 1920x1920\> -quality 78 -sampling-factor 4:2:0 -strip "/tmp/full_$f"
  magick "$f" -auto-orient -resize x600 -quality 72 -sampling-factor 4:2:0 -strip "thumbs/$f"
  mv "/tmp/full_$f" "$f"
done
```

- `-resize 1920x1920\>` only shrinks images bigger than 1920px (the `\>` means
  "shrink larger, never enlarge") — safe to re-run on already-small files.
- `-resize x600` fixes the thumbnail height at 600px (2x the CSS display
  height, for retina) and lets width follow the source aspect ratio.
- `-sampling-factor 4:2:0 -strip` drops chroma resolution and metadata (EXIF,
  color profiles) that don't affect visible quality but add weight.
- Quality 78 (full) / 72 (thumb) is the sweet spot found for these photos —
  visually indistinguishable, ~85% smaller than camera originals.

After adding/renaming photos, **update `gallery/images.json`** — it's a flat
JSON array of filenames in `gallery/` (not the thumbs) and is the single
source of truth `index.html` fetches to build both the grid and the lightbox:

```json
["image_1.jpeg", "image_2.jpeg", ...]
```

The gallery-loading JS in `index.html` (`fetch('gallery/images.json')`)
already points grid `<img>` tags at `gallery/thumbs/${file}` and lightbox
`<img>` tags at `gallery/${file}`, both with `loading="lazy"` — no HTML
changes needed when photos are just swapped/renumbered.

## Hero crossfade photos (site root)

`image1-fade-before/after.*` and `image2-fade-before/after.*` are the two
scroll-crossfade hero images (`.crossfade-img1`/`.crossfade-img2`, `width:
100%` inside the 480px-wide page). Resize to a single flat size — no
thumbnail needed since each is only used once:

```bash
magick <input> -auto-orient -resize 1440x1440\> -quality 82 -sampling-factor 4:2:0 -strip <output>.jpg
```

Always output `.jpg` even if the source is `.png` — these are photos/line-art
with no transparency, and PNG is lossless (much heavier for no visual gain).
If the filename extension changes (png -> jpg), update the `src=` in
`index.html` to match.

## Sanity checks before committing

- `magick identify <file>` — confirm resulting dimensions are ≤ the target box.
- `du -sh gallery/` — the full gallery (photos + thumbs) should land well
  under 10MB total; if it's back in the tens-of-MB range, something wasn't
  run through the resize step.
- Serve locally (`python3 -m http.server`) and spot-check a couple of `<img>`
  URLs with `curl -o /dev/null -w "%{http_code}"` to make sure `images.json`
  and the actual filenames on disk agree (extension typos like `.jpg` vs
  `.jpeg` are the most common break).
