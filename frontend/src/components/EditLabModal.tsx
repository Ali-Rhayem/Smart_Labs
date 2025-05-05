import React, { useState } from "react";
import { Dialog, DialogTitle, DialogContent, Box, Button } from "@mui/material";
import InputField from "./InputField";
import Dropdown from "./Dropdown";
import { useRooms } from "../hooks/useRooms";
import { useSemesters } from "../hooks/useSemesters";
import { Lab, UpdateLabDto } from "../types/lab";
import ScheduleSelect from "./ScheduleSelect";

interface EditLabModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (data: Partial<Lab>) => void;
	lab: Lab;
}

const EditLabModal: React.FC<EditLabModalProps> = ({
	open,
	onClose,
	onSubmit,
	lab,
}) => {
	const { data: rooms = [] } = useRooms();
	const { data: semesters = [] } = useSemesters();

	const [formData, setFormData] = useState<UpdateLabDto>({});
	const [errors, setErrors] = useState<{ [key: string]: string[] }>({});

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		const newErrors: { [key: string]: string[] } = {};

		if (formData.labName?.trim() === "") {
			newErrors.labName = ["Lab name is required"];
		}
		if (formData.labCode?.trim() === "") {
			newErrors.labCode = ["Lab code is required"];
		}
		if (formData.room === "") {
			newErrors.room = ["Room is required"];
		}

		if (Object.keys(newErrors).length > 0) {
			setErrors(newErrors);
			return;
		}

		const updatedData = {
			...formData,
			labName: formData.labName || lab.labName,
			labCode: formData.labCode || lab.labCode,
			room: formData.room || lab.room,
			description: formData.description || lab.description,
			semesterID: formData.semesterID || lab.semesterID,
			schedule: formData.schedule || lab.schedule,
		};

		onSubmit(updatedData);
	};

	return (
		<Dialog
			open={open}
			onClose={() => {
				onClose();
				setFormData({});
			}}
			maxWidth="md"
			fullWidth
			PaperProps={{
				sx: {
					bgcolor: "var(--color-card)",
					color: "var(--color-text)",
				},
			}}
		>
			<DialogTitle sx={{ borderBottom: 1, borderColor: "divider" }}>
				Edit Lab
			</DialogTitle>
			<form onSubmit={handleSubmit}>
				<DialogContent sx={{ mt: 2 }}>
					<Box sx={{ display: "flex", gap: 2, mb: 2 }}>
						<InputField
							id="labName"
							label="Lab Name"
							name="labName"
							type="text"
							value={
								formData.labName == null
									? lab.labName
									: formData.labName
							}
							placeholder="Enter lab name"
							onChange={(e) =>
								setFormData({
									...formData,
									labName: e.target.value,
								})
							}
							error={errors.labName}
						/>
						<InputField
							id="labCode"
							label="Lab Code"
							name="labCode"
							type="text"
							value={
								formData.labCode == null
									? lab.labCode
									: formData.labCode
							}
							placeholder="Enter lab code"
							onChange={(e) =>
								setFormData({
									...formData,
									labCode: e.target.value,
								})
							}
							error={errors.labCode}
						/>
					</Box>

					<InputField
						id="description"
						label="Description"
						name="description"
						type="text"
						value={
							formData.description == null
								? lab.description
								: formData.description
						}
						placeholder="Enter description"
						onChange={(e) =>
							setFormData({
								...formData,
								description: e.target.value,
							})
						}
						multiline
						rows={3}
					/>

					<Box sx={{ display: "flex", gap: 2, mb: 2 }}>
						<Dropdown
							label="Room"
							value={
								formData.room == null ? lab.room : formData.room
							}
							error={errors.room}
							options={rooms.map((room) => ({
								value: room.name,
								label: room.name,
							}))}
							onChange={(value) =>
								setFormData({ ...formData, room: value })
							}
						/>

						<Dropdown
							label="Semester"
							value={(formData.semesterID == null
								? lab.semesterID
								: formData.semesterID
							).toString()}
							options={semesters.map((sem) => ({
								value: sem.id.toString(),
								label: sem.name,
							}))}
							onChange={(value) =>
								setFormData({
									...formData,
									semesterID: Number(value),
								})
							}
						/>
					</Box>

					<ScheduleSelect
						schedules={formData.schedule || lab.schedule}
						onChange={(schedules) =>
							setFormData({
								...formData,
								schedule: schedules,
							})
						}
						error={errors.schedule}
					/>
				</DialogContent>

				<Box
					sx={{
						p: 2,
						borderTop: 1,
						borderColor: "divider",
						display: "flex",
						justifyContent: "flex-end",
						gap: 2,
					}}
				>
					<Button
						onClick={() => {
							onClose();
							setFormData({});
						}}
						sx={{ color: "var(--color-text)" }}
					>
						Cancel
					</Button>
					<Button
						type="submit"
						variant="contained"
						sx={{
							bgcolor: "var(--color-primary)",
							color: "var(--color-text-button)",
							"&:hover": {
								bgcolor:
									"rgb(from var(--color-primary) r g b / 0.8)",
							},
						}}
					>
						Save Changes
					</Button>
				</Box>
			</form>
		</Dialog>
	);
};

export default EditLabModal;
