module Simulation where

import Geographical
import Primitives
import Time

import qualified Prelude
import Data.Time
import Numeric.Units.Dimensional.Prelude
import Text.Printf (printf)

data Simulation = Simulation {
  simTime :: UTCTime,
  simVessels :: [Vessel]
}

instance Show Simulation where
  show s = printf "Simulation\n\
                  \  Time: %s\n\
                  \  Vessels: %s" t v
    where t = show (simTime s)
          v = show (simVessels s)

mkSim :: UTCTime -> Simulation
mkSim utc = Simulation {
  simTime = utc,
  simVessels = []
}

addVessel :: Simulation -> Simulation
addVessel s = s { simVessels = mkVessel : (simVessels s) }

advanceSimBy :: Time' -> Simulation -> Simulation
advanceSimBy t s =
  s { simTime = addTime t (simTime s),
      simVessels = map (advanceVesselBy t) (simVessels s) }


data Vessel = Vessel {
  vesPosition :: Geog,
  vesHeading :: Angle',
  vesRudder :: AngularVelocity',
  vesSpeed :: Velocity'
}

instance Show Vessel where
  show v = printf "Vessel Pos: %s Hdg: %.2f deg" p h
    where h = (vesHeading v) /~ degree
          p = show (vesPosition v)

mkVessel :: Vessel
mkVessel = Vessel {
  vesPosition = mkGeog 32 116,
  vesHeading = 0 *~ degree,
  vesRudder  = 2 *~ (degree / second),
  vesSpeed   = 5 *~ knot
}

advanceVesselBy :: Time' -> Vessel -> Vessel
advanceVesselBy t v = v {
  vesPosition = translate dst hdg pos,
  vesHeading = hdg + (rdr * t)
} where pos = vesPosition v
        hdg = vesHeading v
        rdr = vesRudder v
        spd = vesSpeed v
        dst = spd * t