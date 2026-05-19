import { Link, useLocation, Outlet } from "@tanstack/react-router";
import { LayoutDashboard, Fuel, BarChart3, Car, User, Plus } from "lucide-react";
import type { ReactNode } from "react";

type NavItem = { to: string; label: string; icon: typeof LayoutDashboard; exact?: boolean };
const navItems: NavItem[] = [
  { to: "/", label: "Home", icon: LayoutDashboard, exact: true },
  { to: "/logs", label: "Logs", icon: Fuel },
  { to: "/analytics", label: "Stats", icon: BarChart3 },
  { to: "/vehicles", label: "Garage", icon: Car },
  { to: "/profile", label: "Profile", icon: User },
];

export function AppShell({ children }: { children?: ReactNode }) {
  const location = useLocation();
  const path = location.pathname;

  return (
    <div className="relative mx-auto flex min-h-screen w-full max-w-[480px] flex-col bg-background pb-28">
      <main className="flex-1">{children ?? <Outlet />}</main>

      {/* Floating Add Fuel Button */}
      <Link
        to="/add-fuel"
        aria-label="Add Fuel"
        className="fixed bottom-20 left-1/2 z-40 flex h-16 w-16 -translate-x-1/2 items-center justify-center rounded-full gradient-neon text-neon-foreground shadow-neon ring-4 ring-background transition-transform active:scale-95"
        style={{ marginLeft: "calc(min(50vw, 240px) - 50vw)" }}
      >
        <Plus className="h-7 w-7" strokeWidth={2.5} />
      </Link>

      {/* Bottom Nav */}
      <nav className="fixed bottom-0 left-1/2 z-30 w-full max-w-[480px] -translate-x-1/2 px-3 pb-3">
        <div className="glass flex items-end justify-between rounded-3xl px-2 py-2 shadow-card">
          {navItems.map((item, idx) => {
            const active = item.exact ? path === item.to : path.startsWith(item.to);
            const Icon = item.icon;
            // Insert spacer slot for FAB after 2nd item
            const spacer = idx === 2 ? <div key="sp" className="w-14" /> : null;
            const link = (
              <Link
                key={item.to}
                to={item.to}
                className={`flex flex-1 flex-col items-center gap-1 rounded-2xl px-1 py-2 text-[10px] font-medium transition-colors ${
                  active ? "text-neon" : "text-muted-foreground hover:text-foreground"
                }`}
              >
                <Icon className="h-5 w-5" strokeWidth={active ? 2.4 : 1.8} />
                <span>{item.label}</span>
              </Link>
            );
            return idx === 2 ? (
              <>
                {link}
                {spacer}
              </>
            ) : (
              link
            );
          })}
        </div>
      </nav>
    </div>
  );
}
