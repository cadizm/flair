module Main exposing (Msg(..), main, update, view)

import Basics exposing (degrees)
import Browser
import Element exposing (Element, alignTop, el, padding, paddingEach, paddingXY, rotate, spacing, text)
import Element.Background
import Element.Border as Border
import Element.Font as Font exposing (Font, bold, strike)
import Element.Input as Input
import Html exposing (Html)
import Set.Any exposing (AnySet)


type alias IngredientSet =
    AnySet String Ingredient


type alias Model =
    { recipes : List Recipe
    , sufficient : List Recipe
    , insufficient : List Recipe
    , ingredients : List Ingredient
    , selectedRecipe : Maybe Recipe
    , availableIngredients : IngredientSet
    }


ingredientKey : Ingredient -> String
ingredientKey ingredient =
    ingredient.name


init : Model
init =
    { recipes = recipes
    , ingredients = ingredients
    , selectedRecipe = Nothing
    , availableIngredients = Set.Any.empty ingredientKey
    , sufficient = []
    , insufficient = []
    }
        |> derive


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


type alias Ingredient =
    { name : String
    }


whiskey : Ingredient
whiskey =
    { name = "Whiskey" }


gin : Ingredient
gin =
    { name = "Gin" }


brandy : Ingredient
brandy =
    { name = "Brandy" }


bitters : Ingredient
bitters =
    { name = "Bitters" }


citrusRind : Ingredient
citrusRind =
    { name = "Citrus rind" }


sweetRedVermouth : Ingredient
sweetRedVermouth =
    { name = "Sweet red vermouth" }


whiteVermouth : Ingredient
whiteVermouth =
    { name = "White vermouth" }


sugar : Ingredient
sugar =
    { name = "Sugar" }


campari : Ingredient
campari =
    { name = "Campari" }


gumSyrup : Ingredient
gumSyrup =
    { name = "Gum syrup" }


lemonPeel : Ingredient
lemonPeel =
    { name = "Lemon peel" }


ice : Ingredient
ice =
    { name = "Ice" }


egg : Ingredient
egg =
    { name = "Egg" }


cider : Ingredient
cider =
    { name = "Cider" }


nutmeg : Ingredient
nutmeg =
    { name = "Nutmeg" }


ingredients : List Ingredient
ingredients =
    [ whiskey
    , gin
    , brandy
    , bitters
    , citrusRind
    , sweetRedVermouth
    , campari
    , sugar
    , lemonPeel
    , gumSyrup
    , ice
    , whiteVermouth
    , egg
    , cider
    , nutmeg
    ]


type alias Recipe =
    { name : String
    , ingredients : IngredientSet
    , description : String
    }



--- https://archive.org/stream/modernamericandr00kapp/modernamericandr00kapp_djvu.txt


recipes : List Recipe
recipes =
    [ { name = "Old Fashioned"
      , ingredients =
            Set.Any.fromList
                ingredientKey
                [ whiskey
                , bitters
                , citrusRind
                , sugar
                ]
      , description = """Dissolve a small lump of sugar with a little water in a
      whiskey-glass; add two dashes Angostura bitters, a small piece ice, a piece lemon-peel,
      one jigger whiskey. Mix with small bar-spoon and serve, leaving spoon in the glass."""
      }
    , { name = "Brandy Cocktail"
      , ingredients =
            Set.Any.fromList
                ingredientKey
                [ ice
                , gumSyrup
                , bitters
                , brandy
                , bitters
                , lemonPeel
                ]
      , description = """A mixing-glass half-full fine ice, two dashes 
gum-syrup, two dashes Peyschaud or Angostura 
bitters, one jigger brandy. Mix and strain into 
cocktail-glass. Add a piece twisted lemon-peel or 
a maraschino cherry."""
      }
    , { name = "Manhattan"
      , ingredients =
            Set.Any.fromList
                ingredientKey
                [ bitters
                , whiskey
                , gumSyrup
                , sweetRedVermouth
                , campari
                , lemonPeel
                , ice
                ]
      , description = """Fill mixing-glass half-full fine ice, add two 
dashes gum-syrup, two dashes Peyschaud or Angostura bitters, one half-jigger Italian vermouth, 
one-half jigger whiskey . Mix, strain into cocktail-glass.
Add a piece of lemon-peel or a cherry."""
      }
    , { name = "Cider Egg-Nogg"
      , ingredients =
            Set.Any.fromList
                ingredientKey
                [ sugar
                , egg
                , ice
                , cider
                , nutmeg
                ]
      , description = """One tablespoonful fine sugar, one egg in mixing-glass half-full fine ice ; fill with cider ; mix well, 
strain into long punch-glass, a little grated nutmeg 
on top. This drink is also known as General Harrison Egg-Nogg."""
      }
    ]


type Msg
    = SelectRecipe Recipe
    | ToggleIngredient Ingredient Bool


hasIngredients : IngredientSet -> Recipe -> Bool
hasIngredients availableIngredients recipe =
    Set.Any.isEmpty (Set.Any.diff recipe.ingredients availableIngredients)


derive : Model -> Model
derive model =
    let
        ( sufficient, insufficient ) =
            List.partition (hasIngredients model.availableIngredients) model.recipes
    in
    { model
        | sufficient = sufficient
        , insufficient = insufficient
    }


update : Msg -> Model -> Model
update msg model =
    derive
        (case msg of
            SelectRecipe recipe ->
                { model | selectedRecipe = Just recipe }

            ToggleIngredient ingredient checked ->
                { model
                    | availableIngredients =
                        if checked then
                            Set.Any.insert ingredient model.availableIngredients

                        else
                            Set.Any.remove ingredient model.availableIngredients
                }
        )


background =
    Element.rgb255 249 247 244


black =
    Element.rgb 0 0 0


checkboxIcon : Bool -> Element msg
checkboxIcon checked =
    Element.el
        [ Element.width (Element.px 10)
        , Element.height (Element.px 10)
        , Element.centerY
        , Border.rounded 5
        , Border.color black
        , Element.Background.color <|
            if checked then
                black

            else
                background
        , Border.width 1
        ]
        Element.none


ingredientNavigationItem : IngredientSet -> Ingredient -> Element.Element Msg
ingredientNavigationItem ingredientSet ingredient =
    let
        checked =
            Set.Any.member ingredient ingredientSet
    in
    Input.checkbox []
        { onChange = \_ -> ToggleIngredient ingredient (not checked)
        , icon = checkboxIcon
        , checked = checked
        , label = Input.labelRight [] (text ingredient.name)
        }


edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


title : String -> Element.Element Msg
title name =
    Element.el
        [ bold
        , paddingEach { edges | bottom = 10 }
        ]
        (text name)


listIngredients : Model -> Element.Element Msg
listIngredients model =
    Element.column [ spacing 8, alignTop ]
        (title "CABINET"
            :: List.map (ingredientNavigationItem model.availableIngredients) model.ingredients
        )


leftColumn : Model -> Element.Element Msg
leftColumn model =
    Element.column
        [ spacing 5
        , padding 20
        , alignTop
        , Element.width
            Element.shrink
        ]
        [ listIngredients model
        ]


displayRecipe : Recipe -> Element.Element Msg
displayRecipe recipe =
    Element.column [ spacing 20 ]
        [ Element.el [ Font.italic, Font.underline ] (text recipe.name)
        , Element.row [ spacing 10 ]
            [ Element.column
                [ alignTop, spacing 8, Element.width (Element.px 200) ]
                (List.map
                    (\ingredient -> Element.el [] (text ("◦ " ++ ingredient.name)))
                    (Set.Any.toList recipe.ingredients)
                )
            , Element.paragraph [ alignTop, Element.width Element.fill ] [ text recipe.description ]
            ]
        ]


listRecipes : Model -> Element.Element Msg
listRecipes model =
    Element.column [ spacing 40 ]
        (List.map displayRecipe model.sufficient)


displayOtherRecipe : IngredientSet -> Recipe -> Element.Element Msg
displayOtherRecipe availableIngredients recipe =
    Element.column [ spacing 10 ]
        [ Element.paragraph []
            ([ el [ Font.bold, Font.underline ] (text recipe.name)
             , text " ("
             ]
                ++ List.intersperse
                    (el [] (text ", "))
                    (List.map
                        (\ingredient ->
                            el
                                (if Set.Any.member ingredient availableIngredients then
                                    []

                                 else
                                    [ strike ]
                                )
                                (text ingredient.name)
                        )
                        (Set.Any.toList recipe.ingredients)
                    )
                ++ [ text ")"
                   ]
            )
        ]


listOtherRecipes : Model -> Element.Element Msg
listOtherRecipes model =
    Element.column [ spacing 10 ]
        (List.map (displayOtherRecipe model.availableIngredients) model.insufficient)


rightColumn : Model -> Element.Element Msg
rightColumn model =
    Element.column
        [ alignTop
        , padding 20
        , spacing 5
        , Element.width
            (Element.maximum 640 Element.fill)
        ]
        [ title "WHAT YOU CAN MAKE"
        , listRecipes model
        , title "OTHER"
        , listOtherRecipes model
        ]


view : Model -> Html Msg
view model =
    Element.layout
        [ Element.Background.color background
        , padding 20
        , Font.size 15
        , Element.width Element.fill
        , Font.family
            [ Font.external
                { name = "IBM Plex Mono"
                , url = "https://fonts.googleapis.com/css?family=IBM+Plex+Mono"
                }
            , Font.sansSerif
            ]
        ]
        (Element.row
            [ Element.width Element.fill, Element.height Element.fill, spacing 40 ]
            [ leftColumn model, rightColumn model ]
        )
