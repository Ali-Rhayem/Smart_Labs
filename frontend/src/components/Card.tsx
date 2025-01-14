interface CardProps {
	children: React.ReactNode;
}

const Card = ({ children }: CardProps) => {
	return (
		<div className="bg-gray-800 p-8 rounded-lg shadow-lg w-96">
			{children}
		</div>
	);
};

export default Card;
