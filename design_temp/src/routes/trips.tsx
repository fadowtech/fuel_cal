import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { trips } from "@/lib/mock-data";
import { Play, MapPin, Navigation } from "lucide-react";

export const Route = createFileRoute("/trips")({
  head: () => ({ meta: [{ title: "Trips — FuelMate" }] }),
  component: TripsPage,
});

function TripsPage() {
  return (
    <AppShell>
      <ScreenHeader title="Trips" subtitle="GPS tracked journeys" />
      <div className="px-5 pt-4 space-y-4">
        <button className="flex w-full items-center gap-4 rounded-3xl gradient-neon p-5 text-neon-foreground shadow-neon">
          <div className="flex h-14 w-14 items-center justify-center rounded-full bg-neon-foreground/15"><Play className="h-6 w-6 fill-current" /></div>
          <div className="flex-1 text-left">
            <p className="text-lg font-bold">Start a trip</p>
            <p className="text-xs opacity-80">Auto-track distance & fuel use</p>
          </div>
        </button>

        <div className="space-y-3">
          {trips.map((t) => (
            <div key={t.id} className="rounded-2xl gradient-card p-4 shadow-card">
              <div className="flex items-center gap-2 text-sm">
                <MapPin className="h-4 w-4 text-neon" />
                <span className="font-medium">{t.from}</span>
                <Navigation className="h-3 w-3 text-muted-foreground" />
                <span className="font-medium">{t.to}</span>
              </div>
              <p className="mt-1 text-xs text-muted-foreground">{t.date}</p>
              <div className="mt-3 grid grid-cols-3 gap-2 rounded-xl bg-surface p-3 text-xs">
                <div><p className="text-muted-foreground">Distance</p><p className="font-semibold">{t.distance} KM</p></div>
                <div><p className="text-muted-foreground">Fuel</p><p className="font-semibold">{t.fuel} L</p></div>
                <div><p className="text-muted-foreground">Cost</p><p className="font-semibold text-neon">₹{t.cost}</p></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
