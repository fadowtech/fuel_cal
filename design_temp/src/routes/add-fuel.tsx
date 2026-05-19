import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { useState, useMemo } from "react";
import { Calendar, Camera, Check } from "lucide-react";

export const Route = createFileRoute("/add-fuel")({
  head: () => ({ meta: [{ title: "Add Fuel — FuelMate" }] }),
  component: AddFuelPage,
});

function AddFuelPage() {
  const nav = useNavigate();
  const [liters, setLiters] = useState("22");
  const [price, setPrice] = useState("106.8");
  const [odo, setOdo] = useState("45220");
  const [station, setStation] = useState("Indian Oil");
  const [fullTank, setFullTank] = useState(true);
  const total = (parseFloat(liters || "0") * parseFloat(price || "0")).toFixed(0);
  const mileagePreview = useMemo(() => (parseFloat(liters || "1") > 0 ? (370 / parseFloat(liters)).toFixed(1) : "—"), [liters]);

  const submit = (again: boolean) => {
    if (!again) nav({ to: "/logs" });
  };

  return (
    <AppShell>
      <ScreenHeader title="Add fuel" subtitle="Toyota Innova" back="/" />
      <div className="px-5 pt-4 space-y-4 pb-8">
        {/* Live calc hero */}
        <div className="rounded-3xl gradient-neon p-5 text-neon-foreground shadow-neon">
          <p className="text-xs uppercase tracking-wider opacity-70">Total amount</p>
          <p className="mt-1 text-5xl font-bold tracking-tight">₹{total}</p>
          <div className="mt-3 grid grid-cols-3 gap-2 text-xs">
            <div><p className="opacity-70">Mileage</p><p className="font-bold">{mileagePreview} KM/L</p></div>
            <div><p className="opacity-70">Cost/KM</p><p className="font-bold">₹{(parseFloat(total) / 370).toFixed(2)}</p></div>
            <div><p className="opacity-70">Tank est.</p><p className="font-bold">95%</p></div>
          </div>
        </div>

        <Section title="Fuel details">
          <NumField label="Quantity (L)" value={liters} onChange={setLiters} />
          <NumField label="Price / L (₹)" value={price} onChange={setPrice} />
        </Section>

        <Section title="Odometer">
          <NumField label="Current ODO (KM)" value={odo} onChange={setOdo} />
          <Info label="Trip distance" value="370 KM" />
        </Section>

        <Section title="Station & date">
          <TextField label="Station name" value={station} onChange={setStation} />
          <div className="flex items-center gap-3 rounded-2xl bg-surface px-4 py-3">
            <Calendar className="h-4 w-4 text-muted-foreground" />
            <div className="flex-1">
              <p className="text-xs text-muted-foreground">Date & time</p>
              <p className="text-sm font-medium">Today, 9:14 AM</p>
            </div>
          </div>
        </Section>

        <button onClick={() => setFullTank(!fullTank)} className="flex w-full items-center justify-between rounded-2xl bg-surface px-4 py-3">
          <span className="text-sm">Full tank fill</span>
          <span className={`flex h-6 w-6 items-center justify-center rounded-md ${fullTank ? "gradient-neon" : "bg-muted"}`}>
            {fullTank && <Check className="h-4 w-4 text-neon-foreground" />}
          </span>
        </button>

        <button className="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-border bg-surface/50 py-6 text-sm text-muted-foreground">
          <Camera className="h-5 w-5" /> Upload bill image
        </button>

        <div className="grid grid-cols-2 gap-3 pt-2">
          <button onClick={() => submit(true)} className="rounded-2xl bg-surface py-4 text-sm font-medium">Save & add another</button>
          <button onClick={() => submit(false)} className="rounded-2xl gradient-neon py-4 text-sm font-bold text-neon-foreground shadow-neon">Save fuel</button>
        </div>
      </div>
    </AppShell>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="mb-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">{title}</p>
      <div className="space-y-2">{children}</div>
    </div>
  );
}
function NumField({ label, value, onChange }: { label: string; value: string; onChange: (v: string) => void }) {
  return (
    <div className="rounded-2xl bg-surface px-4 py-3">
      <p className="text-xs text-muted-foreground">{label}</p>
      <input inputMode="decimal" value={value} onChange={(e) => onChange(e.target.value)} className="w-full bg-transparent text-lg font-semibold outline-none" />
    </div>
  );
}
function TextField({ label, value, onChange }: { label: string; value: string; onChange: (v: string) => void }) {
  return (
    <div className="rounded-2xl bg-surface px-4 py-3">
      <p className="text-xs text-muted-foreground">{label}</p>
      <input value={value} onChange={(e) => onChange(e.target.value)} className="w-full bg-transparent text-base font-medium outline-none" />
    </div>
  );
}
function Info({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-surface px-4 py-3">
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="text-base font-semibold text-neon">{value}</p>
    </div>
  );
}
