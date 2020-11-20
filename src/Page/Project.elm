module Page.Project exposing (Model, Msg(..), init, initialModel, update, view)

import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Decode.Extra
import RemoteData
import Task
import Url
import Url.Builder


redirectUrl : Maybe Url.Url
redirectUrl =
    Url.fromString "http://localhost:8081/projects/"


domain : String
domain =
    "https://jsonplaceholder.typicode.com"


type alias Model =
    { id : Int
    , project : RemoteData.WebData Project
    }


initialModel : Model
initialModel =
    { id = 0
    , project = RemoteData.NotAsked
    }


init : Int -> ( Model, Cmd Msg )
init id =
    ( { id = id, project = RemoteData.Loading }
    , fetchProjectCmd id FetchedProject
    )


type Msg
    = FetchedProject (RemoteData.WebData Project)
    | AutoRedirect (Maybe Url.Url) Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedProject result ->
            ( { model | project = result }
            , case result of
                RemoteData.Failure failure ->
                    Task.perform (\_ -> AutoRedirect redirectUrl failure) (Task.succeed ())

                _ ->
                    Cmd.none
            )

        AutoRedirect _ _ ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    case model.project of
        RemoteData.Success post ->
            Html.div
                []
                [ Html.h3 [] [ Html.text <| "Project " ++ String.fromInt model.id ]
                , Html.text post.title
                ]

        RemoteData.NotAsked ->
            Html.div
                [ Html.Attributes.style "padding" "20px" ]
                [ Html.text "NotAsked" ]

        RemoteData.Loading ->
            Html.div
                [ Html.Attributes.style "padding" "20px" ]
                [ Html.text "Loading ..." ]

        RemoteData.Failure failure ->
            Html.div []
                [ Html.span [] [ Html.text "Platform got an error" ]
                , Html.button
                    [ Html.Events.onClick (AutoRedirect redirectUrl failure) ]
                    [ Html.text "Back to projects" ]
                ]


type alias Project =
    { id : Int
    , title : String
    , body : String
    , userId : Int
    }


projectDecoder : Json.Decode.Decoder Project
projectDecoder =
    Json.Decode.succeed Project
        |> Json.Decode.Extra.andMap (Json.Decode.field "id" Json.Decode.int)
        |> Json.Decode.Extra.andMap (Json.Decode.field "title" Json.Decode.string)
        |> Json.Decode.Extra.andMap (Json.Decode.field "body" Json.Decode.string)
        |> Json.Decode.Extra.andMap (Json.Decode.field "userId" Json.Decode.int)


fetchProjectCmd : Int -> (RemoteData.WebData Project -> Msg) -> Cmd Msg
fetchProjectCmd projectId toMsg =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Content-type" "application/x-www-form-urlencoded; charset=UTF-8" ]
        , url = Url.Builder.crossOrigin domain [ "posts", String.fromInt projectId ] []
        , body = Http.emptyBody
        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) projectDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
