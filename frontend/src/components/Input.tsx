interface InputProps {
	id: string;
	type: string;
	placeholder: string;
	label: string;
}

const Input = ({ id, type, placeholder, label }: InputProps) => {
	return (
		<div className="mb-4">
			<label htmlFor={id} className="block text-gray-300 text-sm mb-2">
				{label}
			</label>
			<input
				type={type}
				id={id}
				placeholder={placeholder}
				className="w-full p-3 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
			/>
		</div>
	);
};

export default Input;
