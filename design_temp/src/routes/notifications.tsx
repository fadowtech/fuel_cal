import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { alerts } from "@/lib/mock-data";
import { Bell, AlertTriangle, Wrench, Shield, TrendingDown } from "lucide-react";

export const Route = createFileRoute("/notifications")({
  head: () => ({ meta: [{ title: "Notifications — FuelMate" }] }),
  component: NotificationsPage,
});

function NotificationsPage() {
  return (
    <AppShell>
      <ScreenHeader title="Notifications" subtitle={`${alerts.length} reminders`} />
      <div className="px-5 pt-4 space-y-2">
        {alerts.map((a) => {
          const Icon = a.severity === "danger" ? Shield : a.severity === "warning" ? Wrench : TrendingDown;
          return (
            <div key={a.id} className="flex items-center gap-3 rounded-2xl gradient-card p-4 shadow-card">
              <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${
                a.severity === "danger" ? "bg-danger/15 text-danger" :
                a.severity === "warning" ? "bg-warning/15 text-warning" : "bg-info/15 text-info"
              }`}>
                <Icon className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-semibold">{a.title}</p>
                <p className="text-xs text-muted-foreground">{a.subtitle}</p>
              </div>
              <Bell className="h-4 w-4 text-muted-foreground" />
            </div>
          );
        })}
        <div className="rounded-2xl border border-dashed border-border p-6 text-center">
          <AlertTriangle className="mx-auto h-6 w-6 text-muted-foreground" />
          <p className="mt-2 text-xs text-muted-foreground">You're all caught up</p>
        </div>
      </div>
    </AppShell>
  );
}
