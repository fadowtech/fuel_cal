import { createFileRoute, Link } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { fuelLogs } from "@/lib/mock-data";
import { Filter, Search, Fuel } from "lucide-react";

export const Route = createFileRoute("/logs")({
  head: () => ({ meta: [{ title: "Fuel Logs — FuelMate" }] }),
  component: LogsPage,
});

function LogsPage() {
  return (
    <AppShell>
      <ScreenHeader title="Fuel logs" subtitle={`${fuelLogs.length} entries`} right={
        <button className="flex h-10 w-10 items-center justify-center rounded-full bg-surface"><Filter className="h-4 w-4" /></button>
      } />
      <div className="px-5 pt-4">
        <div className="flex items-center gap-2 rounded-2xl bg-surface px-4 py-3">
          <Search className="h-4 w-4 text-muted-foreground" />
          <input placeholder="Search station name…" className="flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground" />
        </div>

        <div className="mt-4 flex gap-2 overflow-x-auto pb-2 no-scrollbar">
          {["All", "This month", "Petrol", "Diesel", "Full tank"].map((f, i) => (
            <button key={f} className={`whitespace-nowrap rounded-full px-3 py-1.5 text-xs ${i === 0 ? "bg-neon text-neon-foreground" : "bg-surface text-muted-foreground"}`}>{f}</button>
          ))}
        </div>

        <div className="mt-4 space-y-3">
          {fuelLogs.map((log) => (
            <Link key={log.id} to="/logs/$id" params={{ id: log.id }} className="block rounded-2xl gradient-card p-4 shadow-card">
              <div className="flex items-start gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl gradient-neon text-neon-foreground">
                  <Fuel className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <p className="font-semibold">{log.station}</p>
                    <p className="text-sm font-bold">₹{log.amount.toLocaleString()}</p>
                  </div>
                  <p className="mt-0.5 text-xs text-muted-foreground">{new Date(log.date).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })} • ODO {log.odo.toLocaleString()}</p>
                  <div className="mt-3 flex items-center justify-between rounded-xl bg-surface px-3 py-2 text-xs">
                    <span><b>{log.liters}L</b> <span className="text-muted-foreground">filled</span></span>
                    <span className="text-neon font-medium">{log.mileage} KM/L</span>
                    <span className="text-muted-foreground">₹{log.pricePerL}/L</span>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
