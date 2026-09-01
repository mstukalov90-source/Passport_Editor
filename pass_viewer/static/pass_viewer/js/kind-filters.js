(function (global) {
    'use strict';

    const PV = (global.PassViewer = global.PassViewer || {});
    const STORAGE_KEY = 'pv-kind-filters';
    const VALID_KEYS = new Set(['all', 'actualization', 'primary', 'drawn', 'approval']);

    function kindFields(source) {
        if (!source) {
            return { rowKind: '', passportizationKind: '', folded: false };
        }
        const ds = source.dataset;
        if (ds) {
            return {
                rowKind: ds.rowKind || '',
                passportizationKind: ds.passportizationKind || '',
                folded: ds.foldedIntoPassport === '1',
            };
        }
        return {
            rowKind: String(source.rowKind || source.row_kind || ''),
            passportizationKind: String(source.passportizationKind || source.passportization_kind || ''),
            folded: Boolean(source.foldedIntoPassport || source.folded_into_passport),
        };
    }

    function rowMatchesKindFilter(source, active) {
        const { rowKind, passportizationKind, folded } = kindFields(source);
        if (folded) {
            return false;
        }
        if (!rowKind) {
            return true;
        }
        const keys = active instanceof Set ? active : new Set(active || []);
        if (!keys.size) {
            return true;
        }
        if (keys.has('all')) {
            return true;
        }
        if (keys.has('actualization') && passportizationKind === 'Актуализация') {
            return true;
        }
        if (keys.has('primary') && passportizationKind === 'Первичная') {
            return true;
        }
        if (keys.has('drawn') && rowKind === 'request') {
            return true;
        }
        if (keys.has('approval') && rowKind === 'approval') {
            return true;
        }
        return false;
    }

    function setKindFilterPressed(btn, pressed) {
        if (!btn) {
            return;
        }
        btn.setAttribute('aria-pressed', pressed ? 'true' : 'false');
        btn.classList.toggle('is-active', pressed);
    }

    function activeFromButtons(buttons) {
        return new Set(
            (buttons || [])
                .filter((btn) => btn.getAttribute('aria-pressed') === 'true')
                .map((btn) => btn.dataset.kindFilter)
                .filter((key) => VALID_KEYS.has(key))
        );
    }

    function loadKindFilters() {
        try {
            const raw = sessionStorage.getItem(STORAGE_KEY);
            const parsed = JSON.parse(raw);
            if (Array.isArray(parsed)) {
                const keys = parsed.filter((key) => VALID_KEYS.has(key));
                if (keys.length) {
                    return keys;
                }
            }
        } catch (e) {
            // sessionStorage may be unavailable
        }
        return ['all'];
    }

    function saveKindFilters(keys) {
        const list = Array.from(keys instanceof Set ? keys : keys || []).filter((key) => VALID_KEYS.has(key));
        try {
            sessionStorage.setItem(STORAGE_KEY, JSON.stringify(list.length ? list : ['all']));
        } catch (e) {
            // sessionStorage may be unavailable
        }
    }

    function applyKeysToButtons(buttons, keys) {
        const selected = new Set(keys instanceof Set ? keys : keys || ['all']);
        if (!selected.size || (selected.has('all') && selected.size > 1)) {
            selected.clear();
            selected.add('all');
        }
        (buttons || []).forEach((btn) => {
            const key = btn.dataset.kindFilter;
            setKindFilterPressed(btn, selected.has(key));
        });
        return selected;
    }

    function legendGroupsForKindFilters(active) {
        const keys = active instanceof Set ? active : new Set(active || []);
        const groups = new Set();
        if (keys.has('all') || keys.has('actualization') || keys.has('primary')) {
            groups.add('passports');
            groups.add('requests');
        }
        if (keys.has('drawn')) {
            groups.add('requests');
        }
        if (keys.has('all') || keys.has('approval')) {
            groups.add('approvals');
        }
        return groups;
    }

    function bindKindFilters(buttons, onChange) {
        const list = Array.from(buttons || []);
        if (!list.length) {
            return;
        }
        const allKindBtn = list.find((item) => item.dataset.kindFilter === 'all');
        applyKeysToButtons(list, loadKindFilters());

        function emit() {
            const active = activeFromButtons(list);
            saveKindFilters(active);
            if (typeof onChange === 'function') {
                onChange(active);
            }
        }

        list.forEach((btn) => {
            btn.addEventListener('click', () => {
                const filter = btn.dataset.kindFilter;
                if (filter === 'all') {
                    list.forEach((item) => {
                        setKindFilterPressed(item, item === btn);
                    });
                    emit();
                    return;
                }
                const nextPressed = btn.getAttribute('aria-pressed') !== 'true';
                setKindFilterPressed(btn, nextPressed);
                if (nextPressed && allKindBtn) {
                    setKindFilterPressed(allKindBtn, false);
                }
                if (!list.some((item) => item.getAttribute('aria-pressed') === 'true') && allKindBtn) {
                    setKindFilterPressed(allKindBtn, true);
                }
                emit();
            });
        });
        emit();
    }

    PV.kindFilters = {
        STORAGE_KEY,
        rowMatchesKindFilter,
        bindKindFilters,
        loadKindFilters,
        saveKindFilters,
        activeFromButtons,
        applyKeysToButtons,
        legendGroupsForKindFilters,
        setKindFilterPressed,
    };
})(window);
