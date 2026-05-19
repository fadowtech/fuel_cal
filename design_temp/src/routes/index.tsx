import { createFileRoute } from "@tanstack/react-router";
import { Link } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import {
  vehicles, monthlyFuelUsage, mileageTrend, fuelPriceTrend,
  expenseBreakdown, recentActivity, alerts,
} from "@/lib/mock-data";
import {
  Bell, ChevronDown, Fuel, Gauge, Wallet, Activity, AlertTriangle,
  Plus, Receipt, MapPin, Wrench, ScanLine, TrendingUp, TrendingDown,
} from "lucide-react";
import {
  BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  ResponsiveContainer, XAxis, YAxis, Tooltip, AreaChart, Area,
} from "recharts";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "FuelMate — Dashboard" },
      { name: "description", content: "Track fuel, mileage, expenses, and vehicle health in one beautiful mobile app." },
    ],
  }),
  component: Dashboard,
});

const CHART_NEON = "oklch(0.85 0.22 145)";
const CHART_BLUE = "oklch(0.65 0.2 255)";
const PIE_COLORS = [CHART_NEON, CHART_BLUE, "oklch(0.75 0.18 75)", "oklch(0.7 0.2 320)", "oklch(0.7 0.18 200)"];

function Dashboard() {
  const v = vehicles[0];
  return (
    <AppShell>
      <div className="px-5 pt-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-muted-foreground">Good morning 👋</p>
            <h1 className="text-2xl font-semibold tracking-tight">Hi, Tom</h1>
          </div>
          <div className="flex items-center gap-2">
            <button className="relative flex h-10 w-10 items-center justify-center rounded-full bg-surface">
              <Bell className="h-5 w-5" />
              <span className="absolute right-2 top-2 h-2 w-2 rounded-full bg-neon" />
            </button>
            <div className="flex h-10 w-10 items-center justify-center rounded-full gradient-neon text-neon-foreground font-bold">T</div>
          </div>
        </div>

        {/* Vehicle Selector */}
        <button className="mt-5 flex w-full items-center gap-4 rounded-2xl gradient-card p-4 shadow-card">
          <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-surface-elevated text-3xl">{v.image}</div>
          <div className="flex-1 text-left">
            <p className="text-xs text-muted-foreground">Selected vehicle</p>
            <p className="text-base font-semibold">{v.name}</p>
            <p className="text-xs text-muted-foreground">{v.plate}</p>
          </div>
          <ChevronDown className="h-5 w-5 text-muted-foreground" />
        </button>

        {/* Fuel status hero card */}
        <div className="mt-4 overflow-hidden rounded-3xl gradient-card p-5 shadow-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs uppercase tracking-wider text-muted-foreground">Fuel tank</p>
              <p className="mt-1 text-5xl font-bold tracking-tight">65<span className="text-2xl text-muted-foreground">%</span></p>
            </div>
            <div className="flex h-20 w-20 items-center justify-center rounded-full" style={{
              background: `conic-gradient(${CHART_NEON} 0% 65%, oklch(0.25 0.03 250) 65% 100%)`,
            }}>
              <div className="flex h-14 w-14 items-center justify-center rounded-full bg-card">
                <Fuel className="h-6 w-6 text-neon" />
              </div>
            </div>
          </div>
          <div className="mt-4 grid grid-cols-3 gap-3">
            <Stat label="Remaining" value="28L" />
            <Stat label="Range" value="340 KM" />
            <Stat label="Last fill" value="₹2,350" />
          </div>
        </div>

        {/* Mileage + Expense */}
        <div className="mt-4 grid grid-cols-2 gap-3">
          <MetricCard icon={<Gauge className="h-4 w-4" />} label="Mileage" value="18" unit="KM/L"
            footer={<span className="text-neon flex items-center gap-1"><TrendingUp className="h-3 w-3" />Best 22</span>} />
          <MetricCard icon={<Wallet className="h-4 w-4" />} label="This month" value="₹8,900" unit=""
            footer={<span className="text-danger flex items-center gap-1"><TrendingDown className="h-3 w-3" />+₹1.2k</span>} />
        </div>

        {/* ODO summary */}
        <SectionTitle title="Odometer" />
        <div className="rounded-2xl gradient-card p-4 shadow-card">
          <div className="grid grid-cols-3 gap-3">
            <Stat label="ODO" value="45,220" />
            <Stat label="This month" value="1,250 KM" />
            <Stat label="Daily avg" value="42 KM" />
          </div>
        </div>

        {/* Alerts */}
        <SectionTitle title="Upcoming alerts" action="See all" to="/notifications" />
        <div className="space-y-2">
          {alerts.slice(0, 3).map((a) => (
            <div key={a.id} className="flex items-center gap-3 rounded-2xl gradient-card p-3 shadow-card">
              <div className={`flex h-10 w-10 items-center justify-center rounded-xl ${
                a.severity === "danger" ? "bg-danger/15 text-danger" :
                a.severity === "warning" ? "bg-warning/15 text-warning" : "bg-info/15 text-info"
              }`}>
                <AlertTriangle className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium">{a.title}</p>
                <p className="text-xs text-muted-foreground">{a.subtitle}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Quick Actions */}
        <SectionTitle title="Quick actions" />
        <div className="grid grid-cols-5 gap-2">
          <QuickAction icon={<Plus />} label="Fuel" to="/add-fuel" highlight />
          <QuickAction icon={<Receipt />} label="Expense" to="/expenses" />
          <QuickAction icon={<MapPin />} label="Trip" to="/trips" />
          <QuickAction icon={<Wrench />} label="Service" to="/expenses" />
          <QuickAction icon={<ScanLine />} label="Scan" to="/add-fuel" />
        </div>

        {/* Fuel price trend */}
        <SectionTitle title="Fuel price trend" action="7d" />
        <div className="rounded-2xl gradient-card p-4 shadow-card">
          <div className="mb-2 flex items-center gap-4 text-xs">
            <span className="flex items-center gap-1"><span className="h-2 w-2 rounded-full bg-neon" />Petrol</span>
            <span className="flex items-center gap-1"><span className="h-2 w-2 rounded-full" style={{ background: CHART_BLUE }} />Diesel</span>
          </div>
          <div className="h-32">
            <ResponsiveContainer>
              <AreaChart data={fuelPriceTrend}>
                <defs>
                  <linearGradient id="g1" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor={CHART_NEON} stopOpacity={0.4} />
                    <stop offset="100%" stopColor={CHART_NEON} stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="d" tick={{ fill: "oklch(0.66 0.02 250)", fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis hide domain={["dataMin - 1", "dataMax + 1"]} />
                <Tooltip contentStyle={{ background: "oklch(0.18 0.03 250)", border: "1px solid oklch(0.28 0.03 250)", borderRadius: 12, fontSize: 12 }} />
                <Area type="monotone" dataKey="petrol" stroke={CHART_NEON} strokeWidth={2} fill="url(#g1)" />
                <Line type="monotone" dataKey="diesel" stroke={CHART_BLUE} strokeWidth={2} dot={false} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Monthly Fuel Usage */}
        <SectionTitle title="Monthly fuel usage" />
        <div className="rounded-2xl gradient-card p-4 shadow-card">
          <div className="h-40">
            <ResponsiveContainer>
              <BarChart data={monthlyFuelUsage}>
                <XAxis dataKey="month" tick={{ fill: "oklch(0.66 0.02 250)", fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip cursor={{ fill: "oklch(0.25 0.03 250 / 0.4)" }} contentStyle={{ background: "oklch(0.18 0.03 250)", border: "1px solid oklch(0.28 0.03 250)", borderRadius: 12, fontSize: 12 }} />
                <Bar dataKey="liters" fill={CHART_NEON} radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Mileage Trend */}
        <SectionTitle title="Mileage trend" />
        <div className="rounded-2xl gradient-card p-4 shadow-card">
          <div className="h-36">
            <ResponsiveContainer>
              <LineChart data={mileageTrend}>
                <XAxis dataKey="month" tick={{ fill: "oklch(0.66 0.02 250)", fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis hide domain={["dataMin - 1", "dataMax + 1"]} />
                <Tooltip contentStyle={{ background: "oklch(0.18 0.03 250)", border: "1px solid oklch(0.28 0.03 250)", borderRadius: 12, fontSize: 12 }} />
                <Line type="monotone" dataKey="mileage" stroke={CHART_NEON} strokeWidth={3} dot={{ r: 4, fill: CHART_NEON }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Expense Distribution */}
        <SectionTitle title="Expense distribution" />
        <div className="rounded-2xl gradient-card p-4 shadow-card">
          <div className="flex items-center gap-4">
            <div className="h-32 w-32">
              <ResponsiveContainer>
                <PieChart>
                  <Pie data={expenseBreakdown} dataKey="value" innerRadius={32} outerRadius={56} paddingAngle={2}>
                    {expenseBreakdown.map((_, i) => <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} stroke="none" />)}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="flex-1 space-y-1.5">
              {expenseBreakdown.map((e, i) => (
                <div key={e.name} className="flex items-center justify-between text-xs">
                  <span className="flex items-center gap-2">
                    <span className="h-2 w-2 rounded-full" style={{ background: PIE_COLORS[i] }} />
                    {e.name}
                  </span>
                  <span className="font-medium">₹{e.value.toLocaleString()}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Recent activity */}
        <SectionTitle title="Recent activity" action="View all" to="/logs" />
        <div className="space-y-2">
          {recentActivity.map((a) => (
            <div key={a.id} className="flex items-center gap-3 rounded-2xl gradient-card p-3 shadow-card">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-surface-elevated">
                <Activity className="h-5 w-5 text-neon" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium">{a.title}</p>
                <p className="text-xs text-muted-foreground">{a.subtitle}</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-semibold">{a.amount}</p>
                <p className="text-[10px] text-muted-foreground">{a.date}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-[10px] uppercase tracking-wider text-muted-foreground">{label}</p>
      <p className="mt-0.5 text-sm font-semibold">{value}</p>
    </div>
  );
}

function MetricCard({ icon, label, value, unit, footer }: { icon: React.ReactNode; label: string; value: string; unit: string; footer: React.ReactNode }) {
  return (
    <div className="rounded-2xl gradient-card p-4 shadow-card">
      <div className="flex items-center gap-2 text-muted-foreground">{icon}<span className="text-xs">{label}</span></div>
      <p className="mt-2 text-2xl font-bold tracking-tight">{value}<span className="ml-1 text-xs font-normal text-muted-foreground">{unit}</span></p>
      <div className="mt-1 text-[11px]">{footer}</div>
    </div>
  );
}

function SectionTitle({ title, action, to }: { title: string; action?: string; to?: string }) {
  return (
    <div className="mb-2 mt-6 flex items-center justify-between">
      <h2 className="text-sm font-semibold text-muted-foreground">{title}</h2>
      {action && to && <Link to={to} className="text-xs text-neon">{action}</Link>}
      {action && !to && <span className="text-xs text-neon">{action}</span>}
    </div>
  );
}

function QuickAction({ icon, label, to, highlight }: { icon: React.ReactNode; label: string; to: string; highlight?: boolean }) {
  return (
    <Link to={to} className={`flex flex-col items-center gap-1.5 rounded-2xl p-2.5 shadow-card transition active:scale-95 ${highlight ? "gradient-neon text-neon-foreground" : "gradient-card"}`}>
      <div className="flex h-5 w-5 items-center justify-center">{icon}</div>
      <span className="text-[10px] font-medium">{label}</span>
    </Link>
  );
}
