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
            const response = await fetch(
                `${process.env.NEXT_PUBLIC_API_URL}/api/recommendations`,
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

            if (!response.ok) {
                throw new Error("Failed to get recommendations");
            }

            const data = await response.json();
            setLaptops(data.laptops);
        } catch {
            setError("Something went wrong. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="container">
            <h1 className="title">LaptopAI</h1>
            <p className="subtitle">Describe your needs — get the perfect laptop</p>

            <div className="form">
                <textarea
                    className="input"
                    rows={3}
                    placeholder="What will you use the laptop for? (e.g. software development, video editing, gaming)"
                    value={goals}
                    onChange={(e) => setGoals(e.target.value)}
                />
                <div className="input-row">
                    <input
                        className="input"
                        type="number"
                        placeholder="Budget ($)"
                        value={budget}
                        onChange={(e) => setBudget(e.target.value)}
                    />
                    <button
                        className="button"
                        onClick={handleSubmit}
                        disabled={loading || !goals || !budget}
                    >
                        {loading ? "Searching..." : "Find laptops"}
                    </button>
                </div>
            </div>

            {error && <div className="error">{error}</div>}

            {loading && <div className="loading">AI is analyzing your needs...</div>}

            {laptops.length > 0 && (
                <div className="results">
                    {laptops.map((laptop, i) => (
                        <div key={i} className="card">
                            <div className="card-name">{laptop.name}</div>
                            <div className="card-price">${laptop.price}</div>
                            <div className="card-specs">
                                <span className="badge">{laptop.cpu}</span>
                                <span className="badge">{laptop.ram} RAM</span>
                                <span className="badge">{laptop.gpu}</span>
                                <span className="badge">{laptop.storage}</span>
                            </div>
                            <div className="card-why">{laptop.why}</div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}