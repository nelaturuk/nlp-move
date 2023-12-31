/* globals define, $, _ */
/* jshint browser: true, camelcase: false */

define([
  'js/DragDrop/DragHelper',
  'js/Widgets/DiagramDesigner/DiagramDesignerWidget'
], function (DragHelper, DiagramDesignerWidget) {
  'use strict'

  const ModelEditorWidget = function (container, params) {
    params = params || {}
    params.loggerName = 'gme:Widgets:ModelEditor:ModelEditorWidget'

    params.tabsEnabled = true
    params.addTabs = false
    params.deleteTabs = false
    params.reorderTabs = false

    DiagramDesignerWidget.call(this, container, params)

    this.logger.debug('ModelEditorWidget ctor')
  }

  _.extend(ModelEditorWidget.prototype, DiagramDesignerWidget.prototype)

  ModelEditorWidget.prototype._afterManagersInitialized = function () {
    // turn on open btn
    this.enableOpenButton(true)
  }

  ModelEditorWidget.prototype.getDragEffects = function (selectedElements, event) {
    const ctrlKey = event.ctrlKey || event.metaKey
    const altKey = event.altKey
    const shiftKey = event.shiftKey
    let effects = DiagramDesignerWidget.prototype.getDragEffects.apply(this, [selectedElements, event])

    // ALT_KEY --> DRAG_CREATE_INSTANCE
    if (!ctrlKey && altKey && !shiftKey) {
      effects = [DragHelper.DRAG_EFFECTS.DRAG_CREATE_INSTANCE]
    } else if (!ctrlKey && !altKey && shiftKey) {
      effects = [DragHelper.DRAG_EFFECTS.DRAG_CREATE_POINTER]
    }

    return effects
  }

  /* OVERWRITE DiagramDesignerWidget.prototype._dragHelper */
  ModelEditorWidget.prototype._dragHelper = function (el, event, dragInfo) {
    const helperEl = DiagramDesignerWidget.prototype._dragHelper.apply(this, [el, event, dragInfo])
    const dragEffects = DragHelper.getDragEffects(dragInfo)

    if (dragEffects.length === 1) {
      if (dragEffects[0] === DragHelper.DRAG_EFFECTS.DRAG_CREATE_INSTANCE) {
        helperEl.html($('<i class="glyphicon glyphicon-share-alt"></i>')).append(' Create instance...')
      } else if (dragEffects[0] === DragHelper.DRAG_EFFECTS.DRAG_CREATE_POINTER) {
        helperEl.html($('<i class="glyphicon glyphicon-share"></i>')).append(' Create pointer...')
      }
    }

    return helperEl
  }

  return ModelEditorWidget
})
