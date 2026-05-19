import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { useState } from "react";
import { monthlyFuelUsage, mileageTrend, expenseBreakdown } from "@/lib/mock-data";
import { Lightbulb, TrendingDown, TrendingUp } from "lucide-react";
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, ResponsiveContainer, XAxis, YAxis, Tooltip } from "recharts";

export const Route = createFileRoute("/analytics")({
  head: () => ({ meta: [{ title: "Analytics — FuelMate" }] }),
  component: AnalyticsPage,
});

const NEON = "oklch(0.85 0.22 145)";
const BLUE = "oklch(0.65 0.2 255)";
const COLORS = [NEON, BLUE, "oklch(0.75 0.18 75)", "oklch(0.7 0.2 320)", "oklch(0.7 0.18 200)"];

function AnalyticsPage() {
  const [tab, setTab] = useState("Monthly");
  return (
    <AppShell>
      <ScreenHeader title="Analytics" subtitle="Insights & trends" />
      <div className="px-5 pt-4 space-y-4">
        <div className="flex gap-1 rounded-full bg-surface p-1">
          {["Weekly", "Monthly", "Yearly", "Lifetime"].map((t) => (
            <button key={t} onClick={() => setTab(t)} className={`flex-1 rounded-full py-2 text-xs font-medium ${tab === t ? "gradient-neon text-neon-foreground" : "text-muted-foreground"}`}>{t}</button>
          ))}
        </div>

        <div className="grid grid-cols-2 gap-3">
          <Kpi label="Total spend" value="₹54,200" delta="+12%" up />
          <Kpi label="Distance" value="6,820 KM" delta="+8%" up />
          <Kpi label="Avg mileage" value="18.1 KM/L" delta="-2%" />
          <Kpi label="Avg price" value="₹106.8/L" delta="+1%" up />
        </div>

        <Card title="Fuel cost trend">
          <div className="h-44">
            <ResponsiveContainer>
              <LineChart data={monthlyFuelUsage}>
                <XAxis dataKey="month" tick={{ fill: "oklch(0.66 0.02 250)", fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip contentStyle={{ background: "oklch(0.18 0.03 250)", border: "1px solid oklch(0.28 0.03 250)", borderRadius: 12, fontSize: 12 }} />
                <Line type="monotone" dataKey="cost" stroke={NEON} strokeWidth={3} dot={{ r: 4, fill: NEON }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card title="Mileage trend">
          <div className="h-44">
            <ResponsiveContainer>
              <LineChart data={mileageTrend}>
                <XAxis dataKey="month" tick={{ fill: "oklch(0.66 0.02 250)", fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis hide domain={["dataMin - 1", "dataMax + 1"]} />
                <Tooltip contentStyle={{ background: "oklch(0.18 0.03 250)", border: "1px solid oklch(0.28 0.03 250)", borderRadius: 12, fontSize: 12 }} />
                <Line type="monotone" dataKey="mileage" stroke={BLUE} strokeWidth={3} dot={{ r: 4, fill: BLUE }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card title="Monthly comparison">
          <div className="h-44">
            <ResponsiveContainer>
              <BarChart data={monthlyFuelUsage}>
                <XAxis dataKey="month" tick={{ fill: "oklch(0.66 0.02 250)", fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip cursor={{ fill: "oklch(0.25 0.03 250 / 0.4)" }} contentStyle={{ background: "oklch(0.18 0.03 250)", border: "1px solid oklch(0.28 0.03 250)", borderRadius: 12, fontSize: 12 }} />
                <Bar dataKey="liters" fill={NEON} radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card title="Expense breakdown">
          <div className="flex items-center gap-4">
            <div className="h-32 w-32">
              <ResponsiveContainer>
                <PieChart>
                  <Pie data={expenseBreakdown} dataKey="value" innerRadius={32} outerRadius={56} paddingAngle={2}>
                    {expenseBreakdown.map((_, i) => <Cell key={i} fill={COLORS[i]} stroke="none" />)}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="flex-1 space-y-1.5">
              {expenseBreakdown.map((e, i) => (
                <div key={e.name} className="flex items-center justify-between text-xs">
                  <span className="flex items-center gap-2"><span className="h-2 w-2 rounded-full" style={{ background: COLORS[i] }} />{e.name}</span>
                  <span className="font-medium">₹{e.value.toLocaleString()}</span>
                </div>
              ))}
            </div>
          </div>
        </Card>

        <div>
          <p className="mb-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">Smart insights</p>
          <div className="space-y-2">
            <Insight text="Mileage dropped by 8% this month — consider checking tire pressure." />
            <Insight text="Fuel spending increased by ₹1,200 vs last month." />
            <Insight text="You save more when refueling at Indian Oil (avg ₹0.4/L cheaper)." />
          </div>
        </div>
      </div>
    </AppShell>
  );
}

function Kpi({ label, value, delta, up }: { label: string; value: string; delta: string; up?: boolean }) {
  return (
    <div className="rounded-2xl gradient-card p-4 shadow-card">
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="mt-1 text-xl font-bold">{value}</p>
      <p className={`mt-1 flex items-center gap-1 text-[11px] ${up ? "text-neon" : "text-danger"}`}>
        {up ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}{delta}
      </p>
    </div>
  );
}
function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="rounded-2xl gradient-card p-4 shadow-card">
      <p className="mb-2 text-sm font-semibold">{title}</p>
      {children}
    </div>
  );
}
function Insight({ text }: { text: string }) {
  return (
    <div className="flex gap-3 rounded-2xl gradient-card p-3 shadow-card">
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-neon/15 text-neon"><Lightbulb className="h-4 w-4" /></div>
      <p className="text-xs leading-relaxed">{text}</p>
    </div>
  );
}
