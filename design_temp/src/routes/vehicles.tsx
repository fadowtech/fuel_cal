import { createFileRoute, Link } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { vehicles } from "@/lib/mock-data";
import { Plus, ChevronRight } from "lucide-react";

export const Route = createFileRoute("/vehicles")({
  head: () => ({ meta: [{ title: "Garage — FuelMate" }] }),
  component: VehiclesPage,
});

function VehiclesPage() {
  return (
    <AppShell>
      <ScreenHeader title="My garage" subtitle={`${vehicles.length} vehicles`} right={
        <button className="flex h-10 w-10 items-center justify-center rounded-full gradient-neon text-neon-foreground"><Plus className="h-5 w-5" /></button>
      } />
      <div className="px-5 pt-4 space-y-4">
        {vehicles.map((v) => (
          <div key={v.id} className="overflow-hidden rounded-3xl gradient-card shadow-card">
            <div className="flex items-center gap-4 p-5">
              <div className="flex h-20 w-20 items-center justify-center rounded-2xl bg-surface-elevated text-5xl">{v.image}</div>
              <div className="flex-1">
                <p className="text-lg font-bold">{v.name}</p>
                <p className="text-xs text-muted-foreground">{v.plate}</p>
                <span className="mt-2 inline-block rounded-full bg-neon/15 px-2 py-0.5 text-[10px] font-medium text-neon">{v.fuelType}</span>
              </div>
            </div>
            <div className="grid grid-cols-3 gap-2 border-t border-border bg-surface/40 p-4">
              <Mini label="Mileage" value={`${v.currentMileage} KM/L`} />
              <Mini label="ODO" value={v.odo.toLocaleString()} />
              <Mini label="Tank" value={`${v.tankCapacity}L`} />
            </div>
            <button className="flex w-full items-center justify-between border-t border-border px-5 py-3 text-sm">
              View details <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </button>
          </div>
        ))}

        <Link to="/add-fuel" className="flex w-full items-center justify-center gap-2 rounded-2xl border-2 border-dashed border-border py-6 text-sm text-muted-foreground">
          <Plus className="h-5 w-5" /> Add new vehicle
        </Link>
      </div>
    </AppShell>
  );
}

function Mini({ label, value }: { label: string; value: string }) {
  return (
    <div className="text-center">
      <p className="text-[10px] uppercase tracking-wider text-muted-foreground">{label}</p>
      <p className="text-sm font-semibold">{value}</p>
    </div>
  );
}
