import qualified Data.Map as M

import XMonad
import XMonad.Config.Kde
-- to shift and float windows
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.GridSelect

-- Hooks
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Place

-- Utils
import XMonad.Util.EZConfig
import XMonad.Util.Replace
import XMonad.Util.Scratchpad

main = xmonad $ ewmh kde4Config {
    -- replace ; ewmh
    -- kde4Config {

        modMask = mod4Mask -- use the Windows button as mod
      , terminal = "urxvt.sh"

      , manageHook = manageHook kdeConfig <+> myManageHook
      , logHook = myLogHook

    }
    `additionalKeysP`
    [ ("M-<Escape>", kill)
    , ("M-<Space>", sendMessage NextLayout)
    , ("M-r", refresh)
    , ("M-j", windows W.focusDown)
    , ("M-k", windows W.focusUp)
    , ("M-x", goToSelected gsConfig)
    -- MPC keyboard control
    , ("<XF86AudioPlay>", spawn "exec mpc toggle")
    , ("<XF86AudioStop>", spawn "exec mpc stop")
    , ("<XF86AudioPrev>", spawn "exec mpc prev")
    , ("<XF86AudioNext>", spawn "exec mpc next")
    -- My keyboard (a G15) also includes volume controls, but KDE already
    -- manages them.
    -- For reference, the keys are <XF86AudioMute> <XF86AudioRaiseVolume> <XF86AudioLowerVolume>

    -- TODO: This will be replaced by a bashrun (but using zsh!) clone
    , ("M-g", scratchpadSpawnActionTerminal "urxvt" )
    ]

myManageHook = composeAll (

    -- Apps, etc to float & center
    [ className =? c <||> resource =? r <||> title =? t <||> isDialog --> doCenterFloat
    | c <- ["Wine", "Switch2", "quantum-Quantum"]
    , r <- ["Dialog", "Download"]
    , t <- ["Schriftart auswählen", "Choose a directory"]
    ] ++

    -- Separate float apps
    [ className =? "Plasma-desktop" --> doFloat -- For KDE
    , className =? "mplayer" --> doFloat

    -- Workspaces
    -- , className =? "Firefox"      --> makeMaster <+> moveTo 0
    -- , resource =? ""
    -- , title =? ""

    -- "Real" fullscreen
    , isFullscreen              --> doFullFloat
    , isDialog                  --> placeHook (inBounds (underMouse (0,0))) <+> makeMaster <+> doFloat
    ] )

    -- Default hooks:
    -- <+> insertPosition Below Newer
    -- <+> positionStoreManageHook
    <+> manageDocks
    -- TODO: Figure out the rectangle required for a 1-line terminal. (Note: percentages!)
    <+> scratchpadManageHook (W.RationalRect 0.1 0.375 0.15 0.35)

  where makeMaster = insertPosition Master Newer


myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.8

gsConfig = defaultGSConfig
    { gs_cellheight = 30
    , gs_cellwidth = 100
    , gs_navigate = M.unions
        [reset
        ,viStyleKeys
        ,gs_navigate                               -- get the default navigation bindings
            $ defaultGSConfig `asTypeOf` gsConfig  -- needed to fix an ambiguous type variable
        ]
    }
    where addPair (a,b) (x,y) = (a+x,b+y)
          nethackKeys = M.map addPair $ M.fromList
                              [((0,xK_y),(-1,-1))
                              ,((0,xK_i),(1,-1))
                              ,((0,xK_n),(-1,1))
                              ,((0,xK_m),(1,1))
                              ]
          viStyleKeys = M.map addPair $ M.fromList
                              [((0,xK_j),(0,1))
                              ,((0,xK_k),(0,-1))
                              ,((0,xK_h),(-1,0))
                              ,((0,xK_l),(1,0))
                              ]
          -- jump back to the center with the spacebar, regardless of the current position.
          reset = M.singleton (0,xK_space) (const (0,0))

--- vim: set syn=haskell nospell:
