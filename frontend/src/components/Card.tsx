import React from "react";

interface CardProps {
	children: React.ReactNode;
}

const Card: React.FC<CardProps> = ({ children }) => {
	return (
		<div className="w-full max-w-md bg-white dark:bg-gray-800 text-gray-900 dark:text-white rounded-2xl shadow-2xl p-8">
			{children}
		</div>
	);
};

export default Card;
