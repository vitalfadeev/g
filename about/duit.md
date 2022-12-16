# D UI Tree

bottom_panel.duit

```
panel
  w_mode       = WMODE.DISPLAY
  h_mode       = HMODE.FIXED
  layout_mode  = LAYOUT_MODE.HBOX
  childs_align = CHILDS_ALIGN.CENTER

  favorites
    app_btn
      icon = ""
      exec = ""
      text = "explorer"
    app_btn
      icon = ""
      exec = ""
      text = "edge"
    app_btn
      icon = ""
      exec = ""
      text = "aimp"
    app_btn
      icon = ""
      exec = ""
      text = "far"
    app_btn
      icon = ""
      exec = ""
      text = "sublime-text"
    app_btn
      icon = ""
      exec = ""
      text = "sublime-merge"
    app_btn
      icon = ""
      exec = ""
      text = "calc"

    other
```

# D CSS

bottom_panel.dcss

```
app_btn
  w_mode = WMODE.FIXED
  h_mode = HMODE.FIXED
  rect.w = 96
  rect.h = 96
  bg     = SDL_Color(   0,   0,  0, SDL_ALPHA_OPAQUE )
  bind   = panel.AppButton
  class  = panel.AppButton

app_btn:active
  bg = SDL_Color(  48,  48, 48, SDL_ALPHA_OPAQUE )

pressed
  bg = SDL_Color(  48,  48, 48, SDL_ALPHA_OPAQUE )
```

1. Class inheriting
```
// class = panel.AppButton

module panel
class AppButton : Element
{
  //
}
```

```
alias panel = panel.Panel
alias app_btn = panel.AppButton
```

2. Class binding
```
// bind = panel.AppButton

module panel
class AppButton
{
  //
}

{
  e = new Element();
  e.bindo = object.factory( "panel.AppButton" );
}
```

# Render

css_classes["favorites"].render( renderer )

# Events

css_classes["app_btn"].main( e )
e.css_classes = [ "btn", "app_btn", "pressed" ]

# States

normal
pressed
checked
selected
focused
hover
disabled
active

# Element e

Element
  Flag!STATE state;
  string[]   css_classes;

  main( e )
  render( renderer )

  SDL_MOUSEBUTTONDOWN
  SDL_MOUSEWHEEL
  OP.RENDER

# Binds

```
app_btn panel.AppButton
```

```
class panel.AppButton
{
  main( e )
  {
    ...
  }
}
```

```
e.bindo = object.factory( "panel.AppButton" )

class Element
{
  main( e )
  {
    ...

    if ( e.bindo !is null ) 
      e.bindo.main( e )

    ...
  }
}
```

2 memory allocations: Element, panel.AppButton to one allocation:
  - class AppButton : Element

