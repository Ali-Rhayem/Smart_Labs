interface InputProps {
	id: string;
	type: string;
	placeholder: string;
	label: string;
	value: string;
	onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

const Input = ({
	id,
	type,
	placeholder,
	label,
	value,
	onChange,
}: InputProps) => {
	return (
		<div className="mb-4">
			<label htmlFor={id} className="block text-gray-300 text-sm mb-2">
				{label}
			</label>
			<input
				type={type}
				id={id}
				placeholder={placeholder}
				value={value}
				onChange={onChange}
				className="w-full p-3 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
			/>
		</div>
	);
};

export default Input;
