import { createFileRoute, Link } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import {
  Crown, Moon, Languages, IndianRupee, CloudUpload, RefreshCw,
  Fingerprint, Lock, Bell, FileText, ChevronRight, LogOut,
} from "lucide-react";

export const Route = createFileRoute("/profile")({
  head: () => ({ meta: [{ title: "Profile — FuelMate" }] }),
  component: ProfilePage,
});

function ProfilePage() {
  return (
    <AppShell>
      <ScreenHeader title="Profile & Settings" />
      <div className="px-5 pt-4 space-y-4">
        <div className="rounded-3xl gradient-card p-5 shadow-card">
          <div className="flex items-center gap-4">
            <div className="flex h-16 w-16 items-center justify-center rounded-full gradient-neon text-neon-foreground text-2xl font-bold">T</div>
            <div className="flex-1">
              <p className="text-lg font-bold">Tom Hardy</p>
              <p className="text-xs text-muted-foreground">tom@fuelmate.app</p>
              <p className="text-xs text-muted-foreground">+91 98765 43210</p>
            </div>
          </div>
        </div>

        <button className="flex w-full items-center gap-4 rounded-2xl gradient-neon p-4 text-neon-foreground shadow-neon">
          <Crown className="h-6 w-6" />
          <div className="flex-1 text-left">
            <p className="text-sm font-bold">Upgrade to Pro</p>
            <p className="text-xs opacity-80">Unlimited vehicles, reports & cloud sync</p>
          </div>
          <ChevronRight className="h-5 w-5" />
        </button>

        <Group title="App">
          <Row icon={<Moon className="h-4 w-4" />} label="Dark mode" trailing="On" />
          <Row icon={<Languages className="h-4 w-4" />} label="Language" trailing="English" />
          <Row icon={<IndianRupee className="h-4 w-4" />} label="Currency" trailing="INR" />
          <Row icon={<Bell className="h-4 w-4" />} label="Notifications" trailing="Enabled" />
        </Group>

        <Group title="Data">
          <Row icon={<CloudUpload className="h-4 w-4" />} label="Backup" trailing="Today" />
          <Row icon={<RefreshCw className="h-4 w-4" />} label="Restore" />
          <Link to="/reports" className="block"><Row icon={<FileText className="h-4 w-4" />} label="Reports" /></Link>
        </Group>

        <Group title="Security">
          <Row icon={<Lock className="h-4 w-4" />} label="PIN lock" trailing="Off" />
          <Row icon={<Fingerprint className="h-4 w-4" />} label="Fingerprint login" trailing="On" />
        </Group>

        <button className="flex w-full items-center justify-center gap-2 rounded-2xl bg-danger/10 py-4 text-sm font-medium text-danger">
          <LogOut className="h-4 w-4" /> Sign out
        </button>
        <p className="text-center text-[10px] text-muted-foreground">FuelMate v1.0.0</p>
      </div>
    </AppShell>
  );
}

function Group({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="mb-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">{title}</p>
      <div className="overflow-hidden rounded-2xl gradient-card shadow-card divide-y divide-border">{children}</div>
    </div>
  );
}
function Row({ icon, label, trailing }: { icon: React.ReactNode; label: string; trailing?: string }) {
  return (
    <div className="flex items-center gap-3 px-4 py-3.5">
      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-surface text-neon">{icon}</div>
      <p className="flex-1 text-sm">{label}</p>
      {trailing && <p className="text-xs text-muted-foreground">{trailing}</p>}
      <ChevronRight className="h-4 w-4 text-muted-foreground" />
    </div>
  );
}
