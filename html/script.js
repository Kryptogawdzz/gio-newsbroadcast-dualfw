let hideTimeout = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    // ── SHOW TICKER ──────────────────────────────────────────────────────────
    if (data.action === 'showTicker') {
        const intro     = document.getElementById('breakingIntro');
        const ticker    = document.getElementById('ticker');
        const headerEl  = document.getElementById('header-text');
        const track     = document.getElementById('track');
        const labelEl   = document.getElementById('ticker-label');

        // Apply dynamic color from config
        const color = data.color || '#cc0000';
        labelEl.style.backgroundColor = color;
        labelEl.style.borderRightColor = color;

        // Update header label
        headerEl.textContent = data.header || 'NEWS';

        // Set ticker position (bottom or top)
        ticker.classList.remove('bottom', 'top');
        ticker.classList.add(data.position || 'bottom');

        // Build ticker items — repeat 6x for seamless loop
        const fullMessage = `${data.subheader || ''} — ${data.message || ''}`;
        track.innerHTML = '';

        for (let i = 0; i < 6; i++) {
            const item = document.createElement('span');
            item.className = 'ticker-item';

            const tag = document.createElement('span');
            tag.className = 'tag';
            tag.style.background = color;
            tag.textContent = data.header || 'ALERT';

            const text = document.createTextNode('\u00A0' + fullMessage + '\u00A0');

            const sep = document.createElement('span');
            sep.className = 'sep';
            sep.textContent = '|';

            item.appendChild(tag);
            item.appendChild(text);
            item.appendChild(sep);
            track.appendChild(item);
        }

        // Apply scroll speed from config, then reset animation so it starts fresh
        const scrollSpeed = (data.scrollSpeed || 35) + 's';
        track.style.animation = 'none';
        void track.offsetWidth;
        track.style.animation = `ticker-scroll ${scrollSpeed} linear infinite`;

        // Show intro first
        ticker.classList.remove('visible');
        intro.classList.remove('hidden', 'fade-out');

        const introDuration = data.introDuration || 4600;

        // Fade intro out, then show ticker
        setTimeout(() => {
            intro.classList.add('fade-out');

            setTimeout(() => {
                intro.classList.add('hidden');
                ticker.classList.add('visible');

                // Auto-hide if ShowFor > 0
                if (hideTimeout) clearTimeout(hideTimeout);
                const displayTime = data.showFor || 0;
                if (displayTime > 0) {
                    hideTimeout = setTimeout(() => {
                        ticker.classList.remove('visible');
                    }, displayTime);
                }
            }, 650);
        }, introDuration);
    }

    // ── CLEAR TICKER ─────────────────────────────────────────────────────────
    if (data.action === 'clearTicker') {
        const ticker = document.getElementById('ticker');
        const intro  = document.getElementById('breakingIntro');
        ticker.classList.remove('visible');
        intro.classList.add('hidden');
        if (hideTimeout) {
            clearTimeout(hideTimeout);
            hideTimeout = null;
        }
    }
});
