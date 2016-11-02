{CompositeDisposable} = require 'atom'

###*
 * Checks if given string contains anything except spaces and tabs
 * @param  {string}  str the string to check
 * @return {Boolean}     true if the string is blank
###
isStringBlank = (str) -> str.trim().length == 0

module.exports = AtomHungryBackspace =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-smart-backspace:backspace': => @backspace()

  deactivate: ->
    @subscriptions.dispose()

  backspace: ->
    console.log 'Backspace!'
    editor = atom.workspace.getActiveTextEditor()

    cursorPositions = editor.getCursorBufferPositions()

    if cursorPositions.length == 1 # Only when using one cursor
      currRow = cursorPositions[0].row
      prevRow = currRow - 1

      if prevRow > 0 # No hunger in the first row
        currIndentation = editor.indentationForBufferRow currRow
        prevIndentation = editor.indentationForBufferRow prevRow

        currLine = editor.lineTextForBufferRow currRow
        prevLine = editor.lineTextForBufferRow prevRow

        if isStringBlank(currLine) && currIndentation >= prevIndentation && isStringBlank(prevLine)
          missingIndentation = currIndentation - prevIndentation

          # Perform smart backspace
          editor.transact () ->
            editor.deleteLine()
            editor.moveUp()
            editor.insertText editor.getTabText() for [1..missingIndentation] if missingIndentation
            editor.moveToEndOfLine()
          return

    # if we didn't
    editor.backspace()
