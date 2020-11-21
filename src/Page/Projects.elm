module Page.Projects exposing (view)

import Html
import Html.Attributes
import Http
import Notice
import Url.Builder


view : List Http.Error -> Html.Html msg
view errors =
    Html.div
        [ Html.Attributes.style "position" "relative" ]
        [ Html.h3 [] [ Html.text "Projects" ]
        , Html.ul []
            [ internalLinkView "/project/0" "Project 404"
            , internalLinkView "/project/1" "Project 1"
            , internalLinkView "/project/2" "Project 2"
            ]
        , Notice.view errors
        ]


internalLinkView : String -> String -> Html.Html msg
internalLinkView path label =
    Html.li []
        [ Html.a
            [ Html.Attributes.href <|
                Url.Builder.absolute [ String.dropLeft 1 path ] []
            ]
            [ Html.text label ]
        ]
