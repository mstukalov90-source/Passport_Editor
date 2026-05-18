(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    PassViewer.localizeLeafletDraw = function localizeLeafletDraw() {
        if (!global.L || !L.drawLocal) {
            return;
        }
        L.drawLocal.draw.toolbar.actions.title = 'Отменить рисование';
        L.drawLocal.draw.toolbar.actions.text = 'Отмена';
        L.drawLocal.draw.toolbar.finish.title = 'Завершить рисование';
        L.drawLocal.draw.toolbar.finish.text = 'Завершить';
        L.drawLocal.draw.toolbar.undo.title = 'Удалить последнюю точку';
        L.drawLocal.draw.toolbar.undo.text = 'Назад';
        L.drawLocal.draw.toolbar.buttons.polyline = 'Нарисовать линию';
        L.drawLocal.draw.toolbar.buttons.polygon = 'Нарисовать полигон';
        L.drawLocal.draw.toolbar.buttons.rectangle = 'Нарисовать прямоугольник';
        L.drawLocal.draw.toolbar.buttons.circle = 'Нарисовать круг';
        L.drawLocal.draw.toolbar.buttons.marker = 'Поставить маркер';
        L.drawLocal.draw.toolbar.buttons.circlemarker = 'Поставить круглый маркер';
        L.drawLocal.draw.handlers.polyline.tooltip.start = 'Кликните, чтобы начать линию.';
        L.drawLocal.draw.handlers.polyline.tooltip.cont = 'Кликайте, чтобы продолжить линию.';
        L.drawLocal.draw.handlers.polyline.tooltip.end = 'Кликните последнюю точку, чтобы завершить линию.';
        L.drawLocal.draw.handlers.polygon.tooltip.start = 'Кликните, чтобы начать полигон.';
        L.drawLocal.draw.handlers.polygon.tooltip.cont = 'Кликайте, чтобы продолжить полигон.';
        L.drawLocal.draw.handlers.polygon.tooltip.end = 'Кликните первую точку, чтобы замкнуть полигон.';
        L.drawLocal.draw.handlers.rectangle.tooltip.start = 'Нажмите и тяните, чтобы нарисовать прямоугольник.';
        L.drawLocal.draw.handlers.simpleshape.tooltip.end = 'Отпустите кнопку мыши, чтобы завершить фигуру.';
        L.drawLocal.draw.handlers.circle.tooltip.start = 'Нажмите и тяните, чтобы нарисовать круг.';
        L.drawLocal.draw.handlers.marker.tooltip.start = 'Кликните по карте, чтобы поставить маркер.';
        L.drawLocal.edit.toolbar.actions.save.title = 'Сохранить изменения';
        L.drawLocal.edit.toolbar.actions.save.text = 'Сохранить';
        L.drawLocal.edit.toolbar.actions.cancel.title = 'Отменить редактирование, сбросить изменения';
        L.drawLocal.edit.toolbar.actions.cancel.text = 'Отмена';
        L.drawLocal.edit.toolbar.actions.clearAll.title = 'Удалить все объекты';
        L.drawLocal.edit.toolbar.actions.clearAll.text = 'Удалить все';
        L.drawLocal.edit.toolbar.buttons.edit = 'Редактировать объекты';
        L.drawLocal.edit.toolbar.buttons.editDisabled = 'Нет объектов для редактирования';
        L.drawLocal.edit.toolbar.buttons.remove = 'Удалить объекты';
        L.drawLocal.edit.toolbar.buttons.removeDisabled = 'Нет объектов для удаления';
        L.drawLocal.edit.handlers.edit.tooltip.text =
            'Перетаскивайте маркеры или объекты для изменения.';
        L.drawLocal.edit.handlers.edit.tooltip.subtext = 'Нажмите "Отмена", чтобы отменить изменения.';
        L.drawLocal.edit.handlers.remove.tooltip.text = 'Кликните по объекту, чтобы удалить его.';
    };
})(typeof window !== 'undefined' ? window : global);
