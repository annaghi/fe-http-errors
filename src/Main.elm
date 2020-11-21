module Main exposing (main)

import Browser
import Browser.Navigation
import Html
import Html.Attributes
import Http
import Page.Dashboard
import Page.Project
import Page.Projects
import Url
import Url.Builder
import Url.Parser exposing ((</>))



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = ChangeUrl
        , onUrlRequest = ClickLink
        }


redirectUrl : String
redirectUrl =
    "http://localhost:8081/"



-- MODEL


type Page
    = Dashboard
    | Projects
    | Project Int Page.Project.Model
    | NotFound


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , page : Page
    , errors : List Http.Error
    }


init : Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init url key =
    let
        page : Page
        page =
            toPage url
    in
    case page of
        Project id _ ->
            Page.Project.init id
                |> Tuple.mapFirst (\_ -> { key = key, url = url, page = page, errors = [] })
                |> Tuple.mapSecond (Cmd.map ProjectMsg)

        NotFound ->
            case Url.fromString redirectUrl of
                Just url_ ->
                    ( { key = key, url = url_, page = Dashboard, errors = [ Http.BadUrl "not found" ] }
                    , Browser.Navigation.replaceUrl key redirectUrl
                      -- TODO Command for sending report to an error monitoring system (e.g. Sentry)
                    )

                Nothing ->
                    ( { key = key
                      , url = url
                      , page = page
                      , errors = []
                      }
                    , Cmd.none
                    )

        _ ->
            ( { key = key
              , url = url
              , page = page
              , errors = []
              }
            , Cmd.none
            )



-- UPDATE


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
    | ProjectMsg Page.Project.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | errors = [] }
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Browser.Navigation.load href
                    )

        ChangeUrl url ->
            let
                page : Page
                page =
                    toPage url
            in
            case page of
                Project id _ ->
                    Page.Project.init id
                        |> Tuple.mapFirst (\m -> { model | url = url, page = Project id m })
                        |> Tuple.mapSecond (Cmd.map ProjectMsg)

                _ ->
                    ( { model | url = url, page = page }
                    , Cmd.none
                    )

        ProjectMsg subMsg ->
            case subMsg of
                Page.Project.AutoRedirect url failure ->
                    case Url.fromString url of
                        Just url_ ->
                            ( { model | url = url_, page = Projects, errors = failure :: model.errors }
                            , Browser.Navigation.replaceUrl model.key url
                              -- TODO Command for sending report to an error monitoring system (e.g. Sentry)
                            )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    case model.page of
                        Project id subModel ->
                            Page.Project.update subMsg subModel
                                |> Tuple.mapFirst (\m -> { model | page = Project id m })
                                |> Tuple.mapSecond (Cmd.map ProjectMsg)

                        _ ->
                            ( model, Cmd.none )



-- ROUTE


type Route
    = DashboardRoute
    | ProjectsRoute
    | ProjectRoute Int


route : Url.Parser.Parser (Route -> a) a
route =
    Url.Parser.oneOf
        [ Url.Parser.map DashboardRoute Url.Parser.top
        , Url.Parser.map ProjectsRoute (Url.Parser.s "projects")
        , Url.Parser.map ProjectRoute (Url.Parser.s "project" </> Url.Parser.int)
        ]


toPage : Url.Url -> Page
toPage url =
    case Url.Parser.parse route url of
        Just answer ->
            case answer of
                DashboardRoute ->
                    Dashboard

                ProjectsRoute ->
                    Projects

                ProjectRoute n ->
                    Project n (Page.Project.initialModel n)

        Nothing ->
            NotFound



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "fe-http-errors"
    , body =
        [ Html.div
            [ Html.Attributes.style "display" "flex" ]
            [ Html.ul
                [ Html.Attributes.style "width" "150px"
                , Html.Attributes.style "padding" "20px"
                ]
                [ internalLinkView "/" "Dashboard"
                , internalLinkView "/projects/" "Projects"
                ]
            , Html.div
                [ Html.Attributes.style "padding" "20px"
                , Html.Attributes.style "width" "500px"
                ]
                [ case model.page of
                    Dashboard ->
                        Page.Dashboard.view model.errors

                    Projects ->
                        Page.Projects.view model.errors

                    Project _ subModel ->
                        Html.map ProjectMsg (Page.Project.view subModel)

                    NotFound ->
                        Page.Dashboard.view model.errors
                ]
            ]
        ]
    }


internalLinkView : String -> String -> Html.Html msg
internalLinkView path label =
    Html.li []
        [ Html.a
            [ Html.Attributes.href <|
                Url.Builder.absolute [ String.dropLeft 1 path ] []
            ]
            [ Html.text label ]
        ]


notFoundView : Html.Html msg
notFoundView =
    Html.text "Not found"
