"use client";
import { useState } from "react";

interface Laptop {
    name: string;
    price: number;
    cpu: string;
    ram: string;
    gpu: string;
    storage: string;
    why: string;
}

export default function Home() {
    const [goals, setGoals] = useState("");
    const [budget, setBudget] = useState("");
    const [laptops, setLaptops] = useState<Laptop[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async () => {
        if (!goals || !budget) return;
        setLoading(true);
        setError("");
        setLaptops([]);
        try {
            const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
            const response = await fetch(
                `${API_URL}/api/recommendations`,
                {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        goals,
                        budget: parseInt(budget),
                        filters: {},
                    }),
                }
            );
            if (!response.ok) throw new Error("Failed to get recommendations");
            const data = await response.json();
            setLaptops(data.laptops);
        } catch {
            setError("Something went wrong. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    const handleKey = (e: React.KeyboardEvent) => {
        if (e.key === "Enter" && e.metaKey) handleSubmit();
    };

    return (
        <div className="page">
            <header className="hero">
                <div className="logo">✦ AI-Powered</div>
                <h1 className="hero-title">Find your perfect laptop</h1>
                <p className="hero-sub">
                    Describe what you need — our AI finds the best options within your budget
                </p>
            </header>

            <main className="main">
                <div className="form-card">
                    <label className="form-label">What will you use it for?</label>
                    <textarea
                        className="input"
                        rows={3}
                        placeholder="e.g. software development, video editing, gaming, university studies..."
                        value={goals}
                        onChange={(e) => setGoals(e.target.value)}
                        onKeyDown={handleKey}
                    />
                    <div className="form-row">
                        <div>
                            <label className="form-label">Budget</label>
                            <div className="budget-wrap">
                                <span className="budget-prefix">$</span>
                                <input
                                    className="input input-budget"
                                    type="number"
                                    placeholder="1500"
                                    value={budget}
                                    onChange={(e) => setBudget(e.target.value)}
                                    onKeyDown={handleKey}
                                />
                            </div>
                        </div>
                        <button
                            className="btn"
                            onClick={handleSubmit}
                            disabled={loading || !goals || !budget}
                        >
                            {loading ? (
                                <>
                                    <div className="spinner" style={{ width: 16, height: 16, borderWidth: 2 }} />
                                    Searching...
                                </>
                            ) : (
                                <>Find laptops →</>
                            )}
                        </button>
                    </div>
                </div>

                {error && <div className="error-box">{error}</div>}

                {loading && (
                    <div className="loading-box">
                        <div className="spinner" />
                        <p className="loading-text">AI is analyzing your needs...</p>
                    </div>
                )}

                {!loading && laptops.length > 0 && (
                    <>
                        <div className="divider">
                            <span className="results-count">
                                <span>{laptops.length}</span> recommendations found
                            </span>
                        </div>
                        <div className="cards">
                            {laptops.map((laptop, i) => (
                                <div key={i} className="card">
                                    <div className="card-top">
                                        <span className="card-rank">#{i + 1}</span>
                                        <span className="card-name">{laptop.name}</span>
                                        <span className="card-price">${laptop.price}</span>
                                    </div>
                                    <div className="specs">
                                        <span className="spec">
                                            <span className="spec-icon">⬡</span>{laptop.cpu}
                                        </span>
                                        <span className="spec">
                                            <span className="spec-icon">▣</span>{laptop.ram} RAM
                                        </span>
                                        <span className="spec">
                                            <span className="spec-icon">◈</span>{laptop.gpu}
                                        </span>
                                        <span className="spec">
                                            <span className="spec-icon">◫</span>{laptop.storage}
                                        </span>
                                    </div>
                                    <p className="card-why">{laptop.why}</p>
                                </div>
                            ))}
                        </div>
                    </>
                )}

                {!loading && laptops.length === 0 && !error && (
                    <div className="empty-state">
                        <div className="empty-icon">⌨</div>
                        <p className="empty-text">Describe your needs above to get AI recommendations</p>
                    </div>
                )}
            </main>
        </div>
    );
}