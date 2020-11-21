module Notice exposing (view)

import Html
import Html.Attributes
import Html.Extra
import Http


view : List Http.Error -> Html.Html msg
view errors =
    Html.Extra.viewIfLazy (not (List.isEmpty errors))
        (\_ ->
            Html.ul
                [ Html.Attributes.style "border" "1px solid red"
                , Html.Attributes.style "position" "absolute"
                , Html.Attributes.style "right" "0"
                , Html.Attributes.style "top" "0"
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
