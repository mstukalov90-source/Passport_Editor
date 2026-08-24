(function () {
    'use strict';

    const filterToggle = document.getElementById('personal-filter-toggle');
    const filterPanel = document.getElementById('personal-filter-panel');
    const table = document.querySelector('.personal-table');
    const clearButton = document.getElementById('personal-filter-clear');

    if (filterToggle && filterPanel && table) {
        const rows = table.querySelectorAll('tbody tr');
        const inputs = filterPanel.querySelectorAll('input[data-filter-col]');
        const applyFilters = () => {
            rows.forEach((row) => {
                const cells = row.querySelectorAll('td');
                row.hidden = Array.from(inputs).some((input) => {
                    const value = input.value.trim().toLocaleLowerCase('ru');
                    if (!value) return false;
                    const cell = cells[Number(input.dataset.filterCol)];
                    return !cell || !cell.textContent.toLocaleLowerCase('ru').includes(value);
                });
            });
        };
        filterToggle.addEventListener('click', () => {
            const open = filterPanel.hidden;
            filterPanel.hidden = !open;
            filterToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
        inputs.forEach((input) => input.addEventListener('input', applyFilters));
        clearButton?.addEventListener('click', () => {
            inputs.forEach((input) => { input.value = ''; });
            applyFilters();
        });
    }

    const modal = document.getElementById('personal-detail-modal');
    const closeButton = document.getElementById('personal-detail-close');
    const field = (id) => document.getElementById(id);

    function closeModal() {
        if (modal) modal.style.display = 'none';
    }

    document.querySelectorAll('.personal-detail-open').forEach((button) => {
        button.addEventListener('click', () => {
            field('detail-passport-id').textContent = button.dataset.id || '—';
            field('detail-passport-name').textContent = button.dataset.name || '—';
            field('detail-request-id').textContent = button.dataset.requestId || '—';
            field('detail-source').textContent = button.dataset.source === 'ОЗН' ? 'ОО' : (button.dataset.source || '—');
            field('detail-recaps').textContent = button.dataset.recaps || '0';
            field('personal-open-rootid').value = button.dataset.id || '';
            field('personal-open-name').value = button.dataset.name || '';
            field('personal-open-request-id').value = button.dataset.requestId || '';
            field('personal-open-source').value = button.dataset.source || 'ДТ';
            if (modal) modal.style.display = 'flex';
        });
    });

    closeButton?.addEventListener('click', closeModal);
    modal?.addEventListener('click', (event) => {
        if (event.target === modal || event.target.classList.contains('personal-modal__overlay')) closeModal();
    });
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') closeModal();
    });
})();
