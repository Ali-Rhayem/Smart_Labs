import { FC, FormEvent, useState } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
} from "@mui/material";
import { Lab, UpdateLabDto } from "../types/lab";
import { useRooms } from "../hooks/useRooms";
import Dropdown from "./Dropdown";
import InputField from "./InputField";

interface EditLabModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (data: Partial<Lab>) => void;
	lab: Lab;
}

const EditLabModal: FC<EditLabModalProps> = ({
	open,
	onClose,
	onSubmit,
	lab,
}) => {
	const { data: rooms = [] } = useRooms();
	const [formData, setFormData] = useState<UpdateLabDto>({});

	const handleSubmit = (e: FormEvent) => {
		e.preventDefault();
		if (
			!formData.labName &&
			!formData.labCode &&
			!formData.room &&
			!formData.schedule
		) {
			setFormData({});
			onClose();
			return;
		}
		if (!formData.labName) {
			formData.labName = lab.labName;
		}
		if (!formData.labCode) {
			formData.labCode = lab.labCode;
		}
		if (!formData.room) {
			formData.room = lab.room;
		}
		if (!formData.schedule) {
			formData.schedule = lab.schedule;
		}
		if (!formData.semesterID) {
			formData.semesterID = lab.semesterID;
		}
		console.log(formData);
		onSubmit(formData);
	};

	return (
		<Dialog
			open={open}
			onClose={() => {
				onClose();
				setFormData({});
			}}
			maxWidth="sm"
			fullWidth
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background-secondary)",
					color: "var(--color-text)",
				},
			}}
		>
			<DialogTitle>Edit Lab</DialogTitle>
			<form onSubmit={handleSubmit}>
				<DialogContent>
					<InputField
						id="labName"
						label="Lab Name"
						name="labName"
						type="text"
						value={formData?.labName || lab.labName}
						placeholder="Enter lab name"
						onChange={(e) =>
							setFormData({
								...formData,
								labName: e.target.value,
							})
						}
					/>
					<InputField
						id="labCode"
						label="Lab Code"
						name="labCode"
						type="text"
						value={formData.labCode || lab.labCode}
						placeholder="Enter lab code"
						onChange={(e) =>
							setFormData({
								...formData,
								labCode: e.target.value,
							})
						}
					/>
					<InputField
						id="description"
						label="Description"
						name="description"
						type="text"
						value={formData.description || lab.description}
						placeholder="Enter description"
						onChange={(e) =>
							setFormData({
								...formData,
								description: e.target.value,
							})
						}
						multiline
						rows={4}
					/>
					<Dropdown
						label="Room"
						value={formData.room || lab.room}
						options={rooms.map((room) => ({
							value: room.name,
							label: room.name,
						}))}
						onChange={(value) =>
							setFormData({ ...formData, room: value })
						}
					/>
				</DialogContent>
				<DialogActions>
					<Button
						onClick={() => {
							onClose();
							setFormData({});
						}}
						sx={{ color: "var(--color-danger)" }}
					>
						Cancel
					</Button>
					<Button
						type="submit"
						variant="contained"
						sx={{
							backgroundColor: "var(--color-primary)",
							color: "var(--color-text-button)",
						}}
					>
						Save Changes
					</Button>
				</DialogActions>
			</form>
		</Dialog>
	);
};

export default EditLabModal;
