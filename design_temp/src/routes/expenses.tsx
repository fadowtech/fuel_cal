import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { expenses } from "@/lib/mock-data";
import { Plus, Fuel, Wrench, Shield, Car, MapPin, Sparkles, Disc, ShoppingBag } from "lucide-react";

export const Route = createFileRoute("/expenses")({
  head: () => ({ meta: [{ title: "Expenses — FuelMate" }] }),
  component: ExpensesPage,
});

const ICONS: Record<string, React.ReactNode> = {
  Fuel: <Fuel className="h-5 w-5" />,
  Service: <Wrench className="h-5 w-5" />,
  Insurance: <Shield className="h-5 w-5" />,
  Parking: <Car className="h-5 w-5" />,
  Toll: <MapPin className="h-5 w-5" />,
  Washing: <Sparkles className="h-5 w-5" />,
  Tires: <Disc className="h-5 w-5" />,
  Accessories: <ShoppingBag className="h-5 w-5" />,
};

function ExpensesPage() {
  const total = expenses.reduce((s, e) => s + e.amount, 0);
  const categories = ["All", "Fuel", "Service", "Insurance", "Toll", "Parking", "Washing"];

  return (
    <AppShell>
      <ScreenHeader title="Expenses" subtitle="May 2026" right={
        <button className="flex h-10 w-10 items-center justify-center rounded-full gradient-neon text-neon-foreground"><Plus className="h-5 w-5" /></button>
      } />
      <div className="px-5 pt-4 space-y-4">
        <div className="rounded-3xl gradient-card p-5 shadow-card">
          <p className="text-xs uppercase tracking-wider text-muted-foreground">Total spent</p>
          <p className="mt-1 text-4xl font-bold tracking-tight">₹{total.toLocaleString()}</p>
          <p className="text-xs text-muted-foreground">across {expenses.length} entries</p>
        </div>

        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {categories.map((c, i) => (
            <button key={c} className={`whitespace-nowrap rounded-full px-3 py-1.5 text-xs ${i === 0 ? "bg-neon text-neon-foreground" : "bg-surface text-muted-foreground"}`}>{c}</button>
          ))}
        </div>

        <div className="space-y-2">
          {expenses.map((e) => (
            <div key={e.id} className="flex items-center gap-3 rounded-2xl gradient-card p-4 shadow-card">
              <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-surface-elevated text-neon">
                {ICONS[e.category] ?? <ShoppingBag className="h-5 w-5" />}
              </div>
              <div className="flex-1">
                <p className="text-sm font-semibold">{e.title}</p>
                <p className="text-xs text-muted-foreground">{e.category} • {new Date(e.date).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}</p>
              </div>
              <p className="font-bold">₹{e.amount.toLocaleString()}</p>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
