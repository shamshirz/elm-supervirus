module View.Style exposing (theme)

import Css exposing (..)


-- import Html.Styled exposing (..)
-- import Html.Styled.Attributes exposing (css, href, src)


footer : Style
footer =
    Css.batch
        [ backgroundColor theme.primary
        , displayFlex
        , alignItems center
        , justifyContent spaceBetween
        ]


theme : { primary : Color, accent : Color }
theme =
    { primary = (hex "5F9EA0")
    , accent = (hex "8A2BE2")
    }
