import React from "react";

interface CardProps {
	children: React.ReactNode;
}

const Card: React.FC<CardProps> = ({ children }) => {
	return (
		<div
			className="w-full max-w-md rounded-2xl shadow-lg p-8"
			style={{
				backgroundColor: "var(--color-card)",
				color: "var(--color-text)",
			}}
		>
			{children}
		</div>
	);
};

export default Card;
