import command from howl
import app from howl

-- kill
command.register({
  name: 'kill-sexp'
  description: 'Kill the S-expression.'
  handler: () ->
    cursor_position = app.editor.cursor.pos
    l,_ = app.editor.buffer\rfind('(', cursor_position)
    r = app.editor\get_matching_brace(l)
    app.editor.buffer\delete(l,r)
})

-- split
command.register({
  name: 'split-sexp'
  description: 'Split the S-expression.'
  handler: () ->
    pos = app.editor.cursor.pos
    app.editor.buffer\insert ") (", pos
})

-- slurp
command.register({
  name: 'slurp-sexp'
  description: 'Slurp the following sexp'
  handler: () ->
    cursor_position = app.editor.cursor.pos
    l,_ = app.editor.buffer\rfind('(', cursor_position)
    r = app.editor\get_matching_brace(l)
    fl = app.editor.buffer\find('(', r)
    return unless fl
    fr = app.editor\get_matching_brace(fl)
    app.editor.selection\set(fl,fr+1)
    app.editor.buffer\as_one_undo ->
      -- app.editor\with_selection_preserved ->
      text = app.editor.buffer\chunk(fl - (fl-r), fl - (fl-r)).text
      app.editor.buffer\insert(text, fr+1)
      app.editor.buffer\delete fl - (fl-r), fl - (fl-r)
      app.editor.cursor.pos = cursor_position
      howl.command.run("editor-indent-all")
})

-- barf
command.register({
  name: 'barf-sexp'
  description: 'Barf the last expression in the sexp'
  handler: () ->
    cursor_position = app.editor.cursor.pos
    l,_ = app.editor.buffer\rfind('(', cursor_position)
    r = app.editor\get_matching_brace(l)
    fr = app.editor.buffer\rfind(')', r-1)
    return unless fr
    if fr < l
      return
    fl = app.editor\get_matching_brace(fr)
    app.editor.selection\set(fl,fr+1)
    app.editor.buffer\as_one_undo ->
      -- app.editor\with_selection_preserved ->
      text = app.editor.buffer\chunk(fr, fr).text
      app.editor.buffer\delete fr, fr
      app.editor.buffer\insert text, fl - 1
      app.editor.cursor.pos = cursor_position
      app.editor.buffer\replace("%s+%)",")")
      l2,_ = app.editor.buffer\rfind('(', cursor_position)
      r2 = app.editor\get_matching_brace(l2)
      app.editor.buffer\insert("\n", r2+1)
      howl.command.run("editor-indent-all")
})

-- delete
command.register({
  name: 'delete-sexp'
  description: 'Delete the S-expression.'
  handler: () ->
    cursor_position = app.editor.cursor.pos
    l,_ = app.editor.buffer\rfind('(', cursor_position)
    r = app.editor\get_matching_brace(l)
    app.editor.buffer\delete(l,r)
})

-- select
command.register({
  name: 'select-sexp'
  description: 'Select the S-expression.'
  handler: () ->
    cursor_position = app.editor.cursor.pos
    l,_ = app.editor.buffer\rfind('(', cursor_position)
    r = app.editor\get_matching_brace(l)
    app.editor.selection\set(l,r+1)
})

unload = () ->
  command.unregister('select-sexp')
  command.unregister('delete-sexp')
  command.unregister('slurp-sexp')
  command.unregister('barf-sexp')
  command.unregister('kill-sexp')
  command.unregister('split-sexp')

{
  info: {
    author: 'Rok Fajfar',
    description: 'lispy bundle, utility functions for all lisp-based languages'
    license: 'MIT'
  }
  :unload
}
