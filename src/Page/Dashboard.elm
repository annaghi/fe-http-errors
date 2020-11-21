module Page.Dashboard exposing (view)

import Html
import Html.Attributes
import Http
import Notice


view : List Http.Error -> Html.Html msg
view errors =
    Html.div
        [ Html.Attributes.style "position" "relative" ]
        [ Html.h3 [] [ Html.text "Dashboard" ]
        , Notice.view errors
        ]
