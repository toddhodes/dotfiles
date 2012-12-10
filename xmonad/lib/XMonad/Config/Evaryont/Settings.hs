module XMonad.Config.Evaryont.Settings (
      layout_hook,
      log_hook,
      startup_hook,
      handle_events,
      event_hook,
      iconspaces,
      terminal_choice
      ) where

import System.Environment
import XMonad
import XMonad.Actions.UpdateFocus
import XMonad.Actions.UpdatePointer
import XMonad.Config.Kde
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.LayoutHints
import XMonad.Layout.NoBorders (smartBorders)
--import XMonad.Util.EZConfig
--import XMonad.Util.WindowProperties (getProp32s)
import qualified XMonad.Hooks.EwmhDesktops as Ewmh
import XMonad.Util.Cursor

import XMonad.Config.Evaryont.Utils

terminal_choice :: String
terminal_choice = "urxvt"

layout_hook = avoidStruts $ layoutHintsToCenter $ smartBorders $ layoutHook kde4Config

log_hook = takeTopFocus >> updatePointer (Relative 0.5 0.5)

startup_hook = adjustEventInput >> setDefaultCursor xC_left_ptr
handle_events = hintsEventHook <+> focusOnMouseMove

-- apps such as chrome emit correct ewmh events and are handled properly
-- while apps such as vlc use other fullscreen event messages and require
-- X.L.Fullscreen, hence the use of E.fullscreenEventHook and the
-- XMonad.Layout.fullscreenEventHook below
event_hook = Ewmh.ewmhDesktopsEventHook
         <+> Ewmh.fullscreenEventHook
         <+> fullscreenEventHook

-- PLC from Google issues noticed the inconsistencies with XMonad and the
-- default kde4Config's manage hook. Here is the reported & improved version as
-- reported by plc. Use it as a basis for any good, solid KDE config
plcplcConfig = kde4Config {
             manageHook  = ((className =? "krunner") >>= return . not --> manageHook kde4Config)
                       <+> (kdeOverride --> doFloat)
           }

-- Build a path to the directory based on the home directory
bitmaps_path :: String -> String
bitmaps_path home = home ++ "/.icons/dzen/"

--iconspaces :: String -> [WorkspaceId]
iconspaces = [ wrapBitmap "arch_10x10.xbm"
             , wrapBitmap "fox.xbm"
             , wrapBitmap "dish.xbm"
             , wrapBitmap "cat.xbm"
             , wrapBitmap "empty.xbm"
             , wrapBitmap "mail.xbm"
             , wrapBitmap "bug_02.xbm"
             , wrapBitmap "eye_l.xbm"
             , wrapBitmap "eye_r.xbm"
             ]
             where
                wrapBitmap bitmap = "^p(5)^i(" ++ bitmaps_path "/home/colin" ++ bitmap ++ ")^p(5)"

-- vim: set nospell: