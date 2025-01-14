interface ButtonProps {
	text: string;
	type: "submit" | "button";
}

const Button = ({ text, type }: ButtonProps) => {
	return (
		<button
			type={type}
			className="w-full bg-blue-600 hover:bg-blue-500 text-white py-2 px-4 rounded-md transition-colors"
		>
			{text}
		</button>
	);
};

export default Button;
