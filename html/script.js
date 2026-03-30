// ── DOM CACHE ────────────────────────────────────────────────────────────────
// Resolved once at load; never queried again on hot paths.
const intro    = document.getElementById('breakingIntro');
const ticker   = document.getElementById('ticker');
const headerEl = document.getElementById('header-text');
const track    = document.getElementById('track');
const labelEl  = document.getElementById('ticker-label');

// Three tracked timeout handles — all cancelled on each new announcement
// to prevent stale chains from previous cycles interfering (#2)
let hideTimeout  = null;
let introTimeout = null;
let fadeTimeout  = null;

function cancelAllTimeouts() {
    if (hideTimeout)  { clearTimeout(hideTimeout);  hideTimeout  = null; }
    if (introTimeout) { clearTimeout(introTimeout); introTimeout = null; }
    if (fadeTimeout)  { clearTimeout(fadeTimeout);  fadeTimeout  = null; }
}

window.addEventListener('message', function(event) {
    const data = event.data;

    // Guard: ignore null, non-object, or action-less messages
    if (!data || typeof data.action !== 'string') return;

    // ── SHOW TICKER ──────────────────────────────────────────────────────────
    if (data.action === 'showTicker') {
        // Cancel ALL pending timers from any prior announcement cycle (#2)
        cancelAllTimeouts();

        // Apply dynamic color from config
        const color = data.color || '#cc0000';
        labelEl.style.backgroundColor = color;
        labelEl.style.borderRightColor = color;

        // Update header label
        headerEl.textContent = data.header || 'NEWS';

        // Set ticker position (bottom or top)
        ticker.classList.remove('bottom', 'top');
        ticker.classList.add(data.position || 'bottom');

        // Hoist loop constants — evaluated once, not 6x (#6)
        const fullMessage = `${data.subheader || ''} — ${data.message || ''}`;
        const headerText  = data.header || 'ALERT';
        const fragment    = document.createDocumentFragment();

        for (let i = 0; i < 6; i++) {
            const item = document.createElement('span');
            item.className = 'ticker-item';

            const tag = document.createElement('span');
            tag.className = 'tag';
            tag.style.background = color;
            tag.textContent = headerText;

            const text = document.createTextNode('\u00A0' + fullMessage + '\u00A0');

            const sep = document.createElement('span');
            sep.className = 'sep';
            sep.textContent = '|';

            item.appendChild(tag);
            item.appendChild(text);
            item.appendChild(sep);
            fragment.appendChild(item);
        }

        // Atomic DOM swap — clears children and appends in one call (replaceChildren, Chromium 86+)
        track.replaceChildren(fragment);

        // Apply scroll speed from config, then reset animation so it starts fresh
        const scrollSpeed = (data.scrollSpeed || 35) + 's';
        track.style.animation = 'none';
        void track.offsetWidth;
        track.style.animation = `ticker-scroll ${scrollSpeed} linear infinite`;

        // Show intro first
        ticker.classList.remove('visible');
        intro.classList.remove('hidden', 'fade-out');

        const introDuration = data.introDuration || 4600;
        const displayTime   = data.showFor || 0;

        // Tracked timeout chain — cancellable at any point (#2)
        introTimeout = setTimeout(() => {
            introTimeout = null;
            intro.classList.add('fade-out');

            fadeTimeout = setTimeout(() => {
                fadeTimeout = null;
                intro.classList.add('hidden');
                ticker.classList.add('visible');

                if (displayTime > 0) {
                    hideTimeout = setTimeout(() => {
                        hideTimeout = null;
                        ticker.classList.remove('visible');
                    }, displayTime);
                }
            }, 650); // must match CSS fade-out transition on .breaking-intro
        }, introDuration);

    // ── CLEAR TICKER ─────────────────────────────────────────────────────────
    } else if (data.action === 'clearTicker') {
        cancelAllTimeouts();
        ticker.classList.remove('visible');
        intro.classList.add('hidden');
    }
});
