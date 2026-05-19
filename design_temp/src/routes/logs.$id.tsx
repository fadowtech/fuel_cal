import { createFileRoute, notFound } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { fuelLogs } from "@/lib/mock-data";
import { MapPin, FileText, Share2, Pencil, Trash2, CreditCard } from "lucide-react";

export const Route = createFileRoute("/logs/$id")({
  component: LogDetail,
  notFoundComponent: () => <div className="p-8 text-center">Log not found</div>,
});

function LogDetail() {
  const { id } = Route.useParams();
  const log = fuelLogs.find((l) => l.id === id);
  if (!log) throw notFound();

  return (
    <AppShell>
      <ScreenHeader title={log.station} subtitle={new Date(log.date).toDateString()} back="/logs" />
      <div className="px-5 pt-4 space-y-4">
        <div className="rounded-3xl gradient-card p-5 shadow-card">
          <p className="text-xs uppercase tracking-wider text-muted-foreground">Total paid</p>
          <p className="mt-1 text-4xl font-bold tracking-tight">₹{log.amount.toLocaleString()}</p>
          <p className="text-xs text-muted-foreground">{log.liters}L × ₹{log.pricePerL}/L</p>
          <div className="mt-4 grid grid-cols-3 gap-3 border-t border-border pt-4">
            <Field label="Mileage" value={`${log.mileage} KM/L`} />
            <Field label="ODO" value={log.odo.toLocaleString()} />
            <Field label="Full tank" value={log.fullTank ? "Yes" : "No"} />
          </div>
        </div>

        <Row icon={<CreditCard className="h-4 w-4" />} label="Payment" value={log.paymentMethod} />
        <Row icon={<MapPin className="h-4 w-4" />} label="Location" value="MG Road, Pune" />
        <Row icon={<FileText className="h-4 w-4" />} label="Notes" value="Topped up before highway trip." />

        <div className="aspect-[4/3] overflow-hidden rounded-2xl bg-surface flex items-center justify-center text-muted-foreground text-sm">
          📷 Fuel bill image
        </div>

        <div className="grid grid-cols-3 gap-3 pt-2">
          <button className="flex flex-col items-center gap-1 rounded-2xl bg-surface p-3 text-xs"><Pencil className="h-4 w-4" />Edit</button>
          <button className="flex flex-col items-center gap-1 rounded-2xl bg-surface p-3 text-xs"><Share2 className="h-4 w-4" />Share</button>
          <button className="flex flex-col items-center gap-1 rounded-2xl bg-danger/10 p-3 text-xs text-danger"><Trash2 className="h-4 w-4" />Delete</button>
        </div>
      </div>
    </AppShell>
  );
}

function Field({ label, value }: { label: string; value: string }) {
  return <div><p className="text-[10px] uppercase tracking-wider text-muted-foreground">{label}</p><p className="text-sm font-semibold">{value}</p></div>;
}
function Row({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex items-center gap-3 rounded-2xl gradient-card p-4 shadow-card">
      <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-surface-elevated text-neon">{icon}</div>
      <div className="flex-1"><p className="text-xs text-muted-foreground">{label}</p><p className="text-sm font-medium">{value}</p></div>
    </div>
  );
}
