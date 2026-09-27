# KoL Geriatric Buttons

A tiny KoLmafia relay accessibility patch for mall stores.

The goal is to make the fiddly mall controls easier to hit **without redesigning the page or replacing KoL/KoLmafia's native behavior**.

## What it changes

On `mallstore.php`:

- Enlarges the invisible pointer target around each native `whichitem` radio circle to **3× its native width and 3× its native height**.
- Keeps the visible radio circle at its normal KoL size, so the page still looks native.
- Leaves the original radio input and form in place.
- Does **not** intercept keyboard events or replace form submission, so native **Enter-to-buy** behavior remains available.
- Scales KoLmafia's existing item right-click / IRCM popup to **3×** instead of creating a replacement menu.
- Leaves AJAX purchase fragments alone; the patch is injected only into full HTML pages.

This is intentionally a presentation/input-assistance override. The underlying `mallstore.php` page remains authoritative.

## Install with KoLmafia

In the KoLmafia gCLI:

```
git checkout https://github.com/donCannoli-burns/kol-geriatric-buttons main
```

Then reload a mall store in the relay browser.

The repository uses KoLmafia's normal project layout:

```text
relay/
└── mallstore.ash
```

KoLmafia installs the relay override from that directory.

## Updating

In the gCLI:

```
git update kol-geriatric-buttons
```

To update every installed Git project instead:

```
git update
```

## Removing

In the gCLI:

```
git delete kol-geriatric-buttons
```

Then reload the mall page.

## Test checklist

After installing, open an ordinary player mall store through KoLmafia's relay browser.

### 1. Enlarged radio hit area

Find one of the small item-selection radio circles.

- Click a little outside the visible circle.
- The native radio should select.
- The circle itself should still look unchanged.
- The enlarged hit area is invisible.

The target is 3× the radio's width and 3× its height, centered on the original control.

### 2. Native Enter-to-buy behavior

- Select an item using the normal page controls.
- Use the native keyboard flow you normally use to buy with **Enter**.
- It should behave exactly as it did before the override.

This relay does not register `keydown`, `keypress`, or `keyup` handlers.

### 3. Right-click menu

Right-click an item where KoLmafia normally provides its item right-click menu.

- The existing KoLmafia IRCM menu should appear.
- Its contents/actions should be the native ones.
- The popup should render at roughly 3× normal size.
- Near the right or bottom edge of the viewport, its transform origin is adjusted so the enlargement is less likely to grow completely off-screen.

### 4. Purchase behavior

Perform a small normal mall purchase.

The override does not implement purchasing itself. KoL/KoLmafia's existing mall request and AJAX handling remain responsible for the transaction.

## Existing relay override warning

KoLmafia can only have one effective relay override for a given page name.

If you already use another:

```text
relay/mallstore.ash
```

back it up or merge the two overrides before testing this one.

## Implementation notes

The override:

1. Fetches the native page with `visit_url()`.
2. Injects a small CSS/JavaScript accessibility layer before `</head>`.
3. Adds a transparent HTML `label` centered over each native `input[type="radio"][name="whichitem"]`.
4. Associates that label with the real radio using `for=<radio id>`, preserving browser-native selection and focus behavior.
5. Detects KoLmafia IRCM action rows (the `pircm_` elements) and scales their existing positioned popup.
6. Uses a `MutationObserver` so controls or menus inserted later by the page still receive the accessibility treatment.

AJAX purchase responses generally do not contain `</head>`, so `replace_string()` leaves those responses unchanged.

## Scope

This project currently changes only the mall-store relay page.

It does **not**:

- automate purchases;
- choose items;
- alter prices or quantities;
- add new mall actions;
- intercept Enter;
- replace KoLmafia's IRCM actions;
- change the visible KoL radio artwork.

## Troubleshooting

If nothing changes:

1. Confirm the project is installed:

   ```
   git list
   ```

2. Confirm `kol-geriatric-buttons` appears in the list.
3. Hard-reload the mall store page.
4. Make sure another `mallstore.ash` relay override is not winning/conflicting.
5. Test through the KoLmafia relay browser, not a direct `kingdomofloathing.com` browser tab.

If the 3× right-click menu is too large but the radio hit targets feel right, those scales can be separated in a later revision.

## File

The active relay override is:

```text
relay/mallstore.ash
```

Current initial-test build SHA-256:

```text
c4a20cdeb1b0f110afc4050629a2aab05b5c85b10128b5f68e3324270e05c7ea
```
