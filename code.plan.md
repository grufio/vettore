### Vettore Code Plan (updated)

#### Core model (Illustrator-style)
- **Artboard/canvas**: no DPI; size driven by raster pixels only.
- **Image size source of truth**: ,  (4-decimal physical pixels) stored in DB.
- **Raster pixels**: integers derived from physical pixels by rounding; used for OpenCV and preview only.
- **DPI**: image-scoped metadata for unit conversions and export; changing DPI must not change image dimensions or raster data.

#### UI behavior
- **Unit inputs**: width/height show values according to current unit; switching units updates the suffix only, not the numeric text.
- **Formatting**: format on blur; during typing do not rewrite.
- **Resize button enablement**: compare current field text (2-dec) with a stored baseline of last committed physical values. DPI changes reset the baseline to current texts and do not enable Resize.

#### Persistence/operations
- **Commit-on-resize**: persist / only after a successful resize; never on each keystroke.
- **Provider invalidation**: after persisting phys pixels, invalidate ; after resize, invalidate  and .

#### Components & responsibilities
- **ImageDetailService**: compute target physical pixels, persist phys values, perform resize.
- **ImageDetailController**: owns s, reacts to phys pixels and DPI updates.
- **ImageDimensionsSection**: encapsulated dimensions/DPI UI and resize actions.
- **ImagePreview**: derives size strictly from raster pixels.

---

### Status
- DB: added ,  with backfill migration; provider  added.
- Pages:  refactored to use , , .
- DPI handling: dropdown enabled; DPI updates controller DPI only; no field rewrites; baseline reset on DPI change.
- Cleanup: legacy input widgets/services removed; unused symbols/imports dropped; lints fixed in palette pages and chip widget.

---

### Open To-dos
- [ ] Confirm cleanup scope: Dart only vs Dart+scripts vs full repo (final pass)
- [ ] Add tests: DPI no-op; unit-change no rewrite; resize after edit; blur formatting
- [ ] Document the Illustrator model (DPI is metadata; image size = width/height only)

---

### Notes
- Pixel quantization is expected: physical units rarely map exactly to integer pixels at a given DPI. The UI shows 2-dec from phys px; preview rounds to raster.
