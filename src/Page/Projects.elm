module Page.Projects exposing (view)

import Html
import Html.Attributes
import Html.Extra
import Http
import Url.Builder


view : List Http.Error -> Html.Html msg
view errors =
    Html.div
        [ Html.Attributes.style "position" "relative" ]
        [ Html.h3 [] [ Html.text "Projects" ]
        , Html.ul []
            [ internalLinkView "/project/0" "404 Project"
            , internalLinkView "/project/1" "Project 1"
            , internalLinkView "/project/2" "Project 2"
            ]
        , Html.Extra.viewIfLazy (not <| List.isEmpty errors)
            (\_ ->
                Html.ul
                    [ Html.Attributes.style "border" "1px solid red"
                    , Html.Attributes.style "position" "absolute"
                    , Html.Attributes.style "right" "0"
                    , Html.Attributes.style "bottom" "0"
                    ]
                    (List.map
                        (\error ->
                            Html.li
                                []
                                [ case error of
                                    Http.BadUrl badUrl ->
                                        Html.text badUrl

                                    Http.Timeout ->
                                        Html.text "timeout"

                                    Http.NetworkError ->
                                        Html.text "network error"

                                    Http.BadStatus code ->
                                        Html.text <| "bad status " ++ String.fromInt code

                                    Http.BadBody body ->
                                        Html.text body
                                ]
                        )
                        errors
                    )
            )
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
