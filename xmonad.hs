-- Kellegram's main Xmonad config

-----------------------------------------------------------------------------------------------------------
-- Imports                                                                                               --
-----------------------------------------------------------------------------------------------------------

-- Base imports ------------------------------------------------
import System.Exit
import XMonad
import System.IO (hPutStrLn)
import qualified XMonad.StackSet as W

-- Actions imports
import XMonad.Actions.CopyWindow
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.WithAll (killAll, sinkAll)
import qualified XMonad.Actions.Search as S
import qualified XMonad.Actions.TreeSelect as TS


-- Data imports ------------------------------------------------
import qualified Data.Map as M
import Data.Monoid
import Data.Char (isSpace, toUpper)
import Data.Tree

-- Graphics imports --------------------------------------------
import Graphics.X11.ExtraTypes.XF86

-- Hooks imports -----------------------------------------------
import XMonad.Hooks.DynamicLog (statusBar, dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
-- Prompt imports ----------------------------------------------
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import Control.Arrow (first)


-- Layout imports ----------------------------------------------
import XMonad.Config.Desktop
import XMonad.Layout.Spacing
import XMonad.Layout.Renamed
import XMonad.Layout.Tabbed
import XMonad.Layout.LayoutModifier
import XMonad.Layout.SubLayouts
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.Simplest
import XMonad.Layout.ThreeColumns
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.ResizableTile
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Fullscreen    -- fullscreen mode

-- Utility imports ---------------------------------------------
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.SpawnOnce
import XMonad.Util.Run (spawnPipe)


-----------------------------------------------------------------------------------------------------------
-- Basic settings                                                                                        --
-----------------------------------------------------------------------------------------------------------
-- Choose the font
myFont :: String
myFont = "xft:Hack Nerd Font:bold:size=16:antialias=true:hinting=true"

-- Choose which terminal does Xmonad launch
myTerminal :: String
myTerminal = "alacritty"

-- Set the focus to follow mouse
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Make it so that clicking only focuses the windows and doesn't actually pass input
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Set width of the window borders
myBorderWidth :: Dimension
myBorderWidth = 6

-- Set mod key to Super
myModMask :: KeyMask
myModMask = mod4Mask

-- Set focused and unfocused border colors
myNormalBorderColor = gruvGray
myFocusedBorderColor = gruvAquaLight

-- Set a favourite browser for any extension that would need it
myBrowser :: String
myBrowser = "firefox "

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- For clarity
myRestartString :: String
myRestartString = "xmonad --recompile; pkill xmobar; xmonad --restart"


-----------------------------------------------------------------------------------------------------------
-- Gruvbox dark                                                                                          --
-----------------------------------------------------------------------------------------------------------
gruvBg = "#282828"
gruvBgDark = "#1d2021"
gruvBgLight = "#665c54"
gruvFg = "#ebdbb2"
gruvFgDark = "#bdae93"
gruvFgLight = "#fbf1c7"
gruvRed = "#cc241d"
gruvRedLight = "#fb4934"
gruvGreen = "#98971a"
gruvGreenLight = "#b8bb26"
gruvYellow = "#d79921"
gruvYellowLight = "#fabd2f"
gruvBlue = "#458588"
gruvBlueLight = "#83a598"
gruvPurple = "#b16286"
gruvPurpleLight = "#d3869b"
gruvAqua = "#689d6a"
gruvAquaLight = "#8ec07c"
gruvOrange = "#d65d0e"
gruvOrangeLight = "#fe8019"
gruvGray = "#a89984"

-----------------------------------------------------------------------------------------------------------
-- Startup hooks                                                                                         --
-----------------------------------------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
        spawnOnce "xrandr --output eDP-1 --scale 0.75x0.75"
        spawnOnce "nitrogen --restore &" --restore wallpaper/s
        spawnOnce "picom --experimental-backends" --start up picom, experimental-backends will eventually phase out old backends
        spawnOnce "flameshot &"
        spawnOnce "trayer --edge top --align right --widthtype request --SetDockType true --SetPartialStrut true --expand true --transparent false --tint 0x282c34  --height 28 &"

-----------------------------------------------------------------------------------------------------------
-- Keyboard bindings                                                                                     --
-----------------------------------------------------------------------------------------------------------

myKeys :: [(String, X ())]
myKeys =
        -- Basic launching
        [  ("M-t", spawn myTerminal)                                              -- launch a terminal
        ,  ("M-r", spawn "dmenu_run")                                             -- launch dmenu
        ,  ("M-S-s", spawn "flameshot gui")                                       -- Screenshot with Flameshot gui
        -- Xmonad
        ,  ("C-m r", spawn myRestartString)                                       -- Recompile and restart xmonad (kills xmobar too)
        ,  ("C-m q", io (exitWith ExitSuccess))                                   -- Quit xmonad
        -- Kill window/s
        ,  ("M-q", kill1)                                                         -- Close focused window
        ,  ("M-S-q", killAll)                                                     -- Kill all windows on current workspace
        -- Layout
        ,  ("M-<Space>", sendMessage NextLayout)                                  -- Rotate through the available layout algorithms
        ,  ("M-n", refresh)                                                       -- Resize viewed windows to the correct size
        ,  ("M-i", incWindowSpacing 4)
        ,  ("M-o", decWindowSpacing 4)
        ,  ("M-f", sendMessage (T.Toggle "floats"))                               -- Toggles the floats layout
        -- Master tiling layout
        ,  ("M-<Tab>", windows W.focusDown)                                       -- Move focus to the next window
        ,  ("M-j", windows W.focusDown)                                           -- Move focus to the next window
        ,  ("M-k", windows W.focusUp)                                             -- Move focus to the previous window
        ,  ("M-m", windows W.focusMaster)                                         -- Move focus to the master window
        ,  ("M-<Return>", windows W.swapMaster)                                   -- Swap the focused window and the master window
        ,  ("M-S-j", windows W.swapDown)                                          -- Swap the focused window with the next window
        ,  ("M-S-k", windows W.swapUp)                                            -- Swap the focused window with the previous window
        ,  ("M-h", sendMessage Shrink)                                            -- Shrink the master area
        ,  ("M-l", sendMessage Expand)                                            -- Expand the master area
        ,  ("M-,", sendMessage (IncMasterN 1))                                    -- Increment the number of windows in the master area
        ,  ("M-.", sendMessage (IncMasterN (-1)))                                 -- Deincrement the number of windows in the master area
        -- Floating
        ,  ("M1-f t", withFocused $ windows . W.sink)                             -- Push window back into tiling
        ,  ("M1-f a", sinkAll)                                                    -- Push ALL windows back into tiling
        -- Grid Select
        ,  ("C-g s", spawnSelected' myAppGrid)                                    -- Open the custom app grid
        ,  ("C-g g", goToSelected $ mygridConfig myColorizer)                     -- Go to a chosen open window 
        ,  ("C-g b", bringSelected $ mygridConfig myColorizer)                    -- Bring a chosen open window
        -- Tree Select
        ,  ("M1-t", treeselectAction tsDefaultConfig)
        -- Multimedia Keys
        , ("<XF86AudioPlay>", spawn (myTerminal ++ "mocp --play"))
        , ("<XF86AudioPrev>", spawn (myTerminal ++ "mocp --previous"))
        , ("<XF86AudioNext>", spawn (myTerminal ++ "mocp --next"))
        , ("<XF86AudioMute>",   spawn "amixer set Master toggle")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86MonBrightnessUp>", spawn "light -A 5")
        , ("<XF86MonBrightnessDown>", spawn "light -U 5")
        , ("<Print>", spawn "flameshot full")

        ]
        -- Append shortcuts for search prompt
        ++ [("M1-s " ++ k, S.promptSearch myXPConfigNoAutoComplete f) | (k,f) <- searchList ]
        ++ [("M1-S-s " ++ k, S.selectSearch f) | (k,f) <- searchList ]

---------------------------------------------------------------------------------------------------------
-- Mouse bindings                                                                                      --
---------------------------------------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1), ( \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)),
      -- mod-button2, Raise the window to the top of the stack
      ( (modm, button2), (\w -> focus w >> windows W.shiftMaster)),

      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm,button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))

      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


-----------------------------------------------------------------------------------------------------------
-- Layouts                                                                                               --
-----------------------------------------------------------------------------------------------------------
--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- No border if only one window open
mySpacingNoBorder :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacingNoBorder i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Override the color scheme for tabs
myTabColors = def { fontName            = myFont
                  , activeColor         = gruvBlue
                  , inactiveColor       = gruvGray
                  , activeBorderColor   = gruvBlue
                  , inactiveBorderColor = gruvBlue
                  , activeTextColor     = gruvFg
                  , inactiveTextColor   = gruvBgLight
                  }

tall     = renamed [Replace "tall"] -- normal tiling
           $ windowNavigation
           $ limitWindows 20
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
-- This is a layout modifier that will make a layout increase the size of the window that has focus.
magnify  = renamed [Replace "magnify"]
           $ windowNavigation
           $ magnifier
           $ limitWindows 20
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ limitWindows 20
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ limitWindows 7
           $ mySpacing 4
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ windowNavigation
           $ limitWindows 7
           $ mySpacing 4
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           $ tabbed shrinkText myTabColors


-- The layout hook
myLayout = avoidStruts $  T.toggleLayouts floats
               $ myDefaultLayout
             where
               -- Any layout that you want to use out of the defined ones goes here
               myDefaultLayout =     tall
                                 ||| magnify
                                 ||| threeCol
                                 ||| threeRow
                                 ||| noBorders tabs
                                 ||| Full


-----------------------------------------------------------------------------------------------------------
-- Window rules                                                                                          --
-----------------------------------------------------------------------------------------------------------

-- Here you can add any rules for apps that you always want to spawn in a specific way
-- For example "className =? "Gimp" --> doFloat" will make it always Float, even in tiling layouts
myManageHook =
  composeAll
    [ className =? "MPlayer" --> doFloat,
      className =? "Gimp" --> doFloat,
      resource =? "desktop_window" --> doIgnore,
      resource =? "kdesktop" --> doIgnore
    ]


-----------------------------------------------------------------------------------------------------------
-- Log Hook                                                                                              --
-----------------------------------------------------------------------------------------------------------

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.95




-----------------------------------------------------------------------------------------------------------
-- Grid select                                                                                           --
-----------------------------------------------------------------------------------------------------------
-- Use the colorizer to set some colors for the grid
myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0xfb,0xf1,0xc7) -- lowest inactive bg
                  (0xfb,0xf1,0xc7) -- highest inactive bg
                  (0x1d,0x20,0x21) -- active bg
                  (0xfb,0xf1,0xc7) -- inactive fg
                  (0xb8,0xbb,0x26) -- active fg

mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 50
    , gs_cellwidth    = 150
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

-- Define a list of apps for the app grid, the grid will know how to draw itself, so just list them
myAppGrid = [ ("Firefox", "firefox")
            , ("Geary", "geary")
            , ("Gimp", "gimp")
            , ("OBS", "obs")
            , ("Files", "dolphin")
            ]

-----------------------------------------------------------------------------------------------------------
-- Tree select                                                                                           --
-----------------------------------------------------------------------------------------------------------

-- Design the Tree Select, any number of nodes can be used and it can go many layers deep
-- More examples present in the docs for TreeSelect module

treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "Common apps" "My common applications" (return ()))
       [ Node (TS.TSNode "Firefox" "Firefox browser" (spawn "firefox")) []
       , Node (TS.TSNode "Clementine" "A music player" (spawn "clementine")) []
       , Node (TS.TSNode "VSCode" "Code editor"(spawn "code")) []
       ]
   , Node (TS.TSNode "Test" "test" (return ()))
       [ Node (TS.TSNode "Test1" "Test1 desc" (spawn "code")) []
       , Node (TS.TSNode "Test2" "Test2 desc" (spawn "dolphin")) []
       ]
   ]

-- Some config for treeselect
tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd1d2021 -- Tree select doesn't expect a string for color, but rather aarrggbb
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xfffbc7f1, 0xff665c54)
                              , TS.ts_nodealt      = (0xfffbc7f1, 0xff665c54)
                              , TS.ts_highlight    = (0xff8e7cc0, 0xff282828)
                              , TS.ts_extra        = 0xff8398a5
                              , TS.ts_node_width   = 250
                              , TS.ts_node_height  = 40
                              , TS.ts_originX      = 100 --This does nothing
                              , TS.ts_originY      = 100 --This also seems to do nothing ?
                              , TS.ts_indent       = 60
                              , TS.ts_navigate     = TS.defaultNavigation 
                              }


-----------------------------------------------------------------------------------------------------------
-- Search                                                                                                --
-----------------------------------------------------------------------------------------------------------

-- Define a search prompt. Some search engines are included in the library (Prefixed with "S.")
-- but any can be added, as long as a URL that expects a search term at the end exists

-- Declare some additional search engines
archwiki, udict :: S.SearchEngine

archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
udict    = S.searchEngine "urbandict" "https://www.urbandictionary.com/define.php?term="

-- Define a character used with a keybind to pick which search prompt should open
searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
             , ("d", S.duckduckgo)
             , ("g", S.google)
             , ("i", S.images)
             , ("w", S.wayback)
             , ("u", udict)
             , ("w", S.wikipedia)
             , ("y", S.youtube)
             , ("z", S.amazon)
             ]


-----------------------------------------------------------------------------------------------------------
-- Custom XMonad Prompt                                                                                  --
-----------------------------------------------------------------------------------------------------------
myXPConfig :: XPConfig
myXPConfig = def
      { font                = myFont -- might want to change it depending on screen resolution
      , bgColor             = gruvBg
      , fgColor             = gruvFg
      , bgHLight            = gruvFg
      , fgHLight            = gruvBg
      , borderColor         = gruvAqua -- The color doesn't matter, this border sucks
      , promptBorderWidth   = 0 -- Hidden, see above
      , promptKeymap        = myXPKeymap -- pass the self-defined keybinds
      , position            = Top
      , height              = 20
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 100000
      , showCompletionOnTab = False
      , searchPredicate     = fuzzyMatch
      , defaultPrompter     = id $ map toUpper
      , alwaysHighlight     = True
      , maxComplRows        = Nothing
      }

-- Copy myXPConfig, but disable autocomplete, some prompts might not work great with it
myXPConfigNoAutoComplete :: XPConfig
myXPConfigNoAutoComplete = myXPConfig
      { autoComplete        = Nothing
      }

-- Define some keybinds for use in the prompts, as otherwise they will accept all keys as input
myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
     map (first $ (,) controlMask)   -- control + <key>
     [ (xK_BackSpace, killWord Prev) -- kill the previous word
     , (xK_v, pasteString)           -- paste a string
     , (xK_q, quit)                  -- quit out of prompt
     , (xK_Return, setSuccess True >> setDone True)
     ]


-----------------------------------------------------------------------------------------------------------
-- Xbobar                                                                                                --
-----------------------------------------------------------------------------------------------------------

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)


xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = clickable . (map xmobarEscape)
               -- $ [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
               $ [" www ", " chat ", " dev ", " git ", " audio "]
  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

-----------------------------------------------------------------------------------------------------------
-- Main                                                                                                  --
-----------------------------------------------------------------------------------------------------------
-- Everything defined before is put in play here                                                         --
-----------------------------------------------------------------------------------------------------------

main :: IO ()
main = do
  xbar <- spawnPipe "xmobar $HOME/.config/xmobar/xmobarrc"
  
  xmonad $ ewmh desktopConfig { 
      terminal            = myTerminal
    , modMask             = myModMask
    , borderWidth         = myBorderWidth
    , focusFollowsMouse   = myFocusFollowsMouse
    , clickJustFocuses    = myClickJustFocuses
    , workspaces          = myWorkspaces
    , normalBorderColor   = myNormalBorderColor
    , focusedBorderColor  = myFocusedBorderColor
    , mouseBindings       = myMouseBindings
    , startupHook         = myStartupHook
    , layoutHook          = myLayout
    , handleEventHook     = docksEventHook
    , manageHook          = myManageHook  <+> manageDocks
    , logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xbar
                , ppCurrent = xmobarColor gruvAqua "" . wrap "[" "]" -- Current workspace in xmobar
                , ppVisible = xmobarColor gruvAqua ""                -- Visible but not current workspace
                , ppHidden = xmobarColor gruvYellow "" . wrap ":" ":"   -- Hidden workspaces in xmobar
                , ppHiddenNoWindows = xmobarColor gruvGray ""        -- Hidden workspaces (no windows)
                , ppTitle = xmobarColor gruvBlue "" . shorten 30     -- Title of active window in xmobar
                , ppUrgent = xmobarColor gruvRed "" . wrap "!" "!"  -- Urgent workspace
                , ppSep     = " | "
                , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                }
    } `additionalKeysP` myKeys
