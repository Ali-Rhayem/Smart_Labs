import React, { useState } from "react";
import { Dialog, DialogTitle, DialogContent, Box, Button } from "@mui/material";
import InputField from "./InputField";
import Dropdown from "./Dropdown";
import { useRooms } from "../hooks/useRooms";
import { useSemesters } from "../hooks/useSemesters";
import { useAllPPEs } from "../hooks/usePPE";
import { CreateLabDto } from "../types/lab";
import MultiSelect from "./MultiSelect";
import { PPE } from "../types/ppe";
import ScheduleSelect from "./ScheduleSelect";

interface CreateLabModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (data: CreateLabDto) => void;
}

const CreateLabModal: React.FC<CreateLabModalProps> = ({
	open,
	onClose,
	onSubmit,
}) => {
	const { data: rooms = [] } = useRooms();
	const { data: semesters = [] } = useSemesters();
	const { data: ppes = [] } = useAllPPEs();

	const [formData, setFormData] = useState<CreateLabDto>({
		lab: {
			room: "",
			description: "",
			labName: "",
			labCode: "",
			ppe: [],
			schedule: [],
			semesterID: 0,
		},
		instructor_Emails: [],
		student_Emails: [],
	});

	const [errors, setErrors] = useState<{ [key: string]: string[] }>({});

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		console.log(formData);
		const newErrors: { [key: string]: string[] } = {};

		if (!formData.lab.labName.trim())
			newErrors.labName = ["Lab name is required"];
		if (!formData.lab.labCode.trim())
			newErrors.labCode = ["Lab code is required"];
		if (!formData.lab.room) newErrors.room = ["Room is required"];

		if (Object.keys(newErrors).length > 0) {
			setErrors(newErrors);
			return;
		}

		onSubmit(formData);
	};

	const validateEmail = (email: string) => {
		return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
	};

	return (
		<Dialog
			open={open}
			onClose={onClose}
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
				Create New Lab
			</DialogTitle>
			<form onSubmit={handleSubmit}>
				<DialogContent sx={{ mt: 2 }}>
					<Box sx={{ display: "flex", gap: 2, mb: 2 }}>
						<InputField
							id="labName"
							label="Lab Name"
							name="labName"
							type="text"
							value={formData.lab.labName}
							placeholder="Enter lab name"
							onChange={(e) =>
								setFormData({
									...formData,
									lab: {
										...formData.lab,
										labName: e.target.value,
									},
								})
							}
							error={errors.labName}
						/>
						<InputField
							id="labCode"
							label="Lab Code"
							name="labCode"
							type="text"
							value={formData.lab.labCode}
							placeholder="Enter lab code"
							onChange={(e) =>
								setFormData({
									...formData,
									lab: {
										...formData.lab,
										labCode: e.target.value,
									},
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
						value={formData.lab.description || ""}
						placeholder="Enter lab description"
						onChange={(e) =>
							setFormData({
								...formData,
								lab: {
									...formData.lab,
									description: e.target.value,
								},
							})
						}
						multiline
						rows={3}
					/>

					<Box sx={{ display: "flex", gap: 2, mb: 2 }}>
						<Dropdown
							label="Room"
							value={formData.lab.room}
							error={errors.room}
							options={rooms.map((room) => ({
								value: room.name,
								label: room.name,
							}))}
							onChange={(value) =>
								setFormData({
									...formData,
									lab: {
										...formData.lab,
										room: value,
									},
								})
							}
						/>

						<Dropdown
							label="Semester"
							value={formData.lab.semesterID?.toString() || ""}
							options={semesters.map((sem) => ({
								value: sem.id.toString(),
								label: sem.name,
							}))}
							onChange={(value) =>
								setFormData({
									...formData,
									lab: {
										...formData.lab,
										semesterID: Number(value),
									},
								})
							}
						/>
					</Box>

					<MultiSelect<string>
						label="Instructor Emails"
						value={formData.instructor_Emails}
						onChange={(emails) =>
							setFormData({
								...formData,
								instructor_Emails: emails,
							})
						}
						placeholder="Add instructor emails"
						error={errors.instructor_Emails}
						freeSolo
						validate={validateEmail}
					/>

					<MultiSelect<string>
						label="Student Emails"
						value={formData.student_Emails}
						onChange={(emails) =>
							setFormData({ ...formData, student_Emails: emails })
						}
						placeholder="Add student emails"
						error={errors.student_Emails}
						freeSolo
						validate={validateEmail}
					/>

					<MultiSelect<PPE>
						label="Required PPE"
						value={
							ppes?.filter((p) =>
								formData.lab.ppe.includes(p.id)
							) || []
						}
						onChange={(selected) =>
							setFormData({
								...formData,
								lab: {
									...formData.lab,
									ppe: selected.map((p) => p.id),
								},
							})
						}
						options={ppes || []}
						getOptionLabel={(option: string | PPE) =>
							typeof option === "string" ? option : option.name
						}
						placeholder="Select required PPE"
					/>

					<ScheduleSelect
						schedules={formData.lab.schedule}
						onChange={(schedules) =>
							setFormData({
								...formData,
								lab: {
									...formData.lab,
									schedule: schedules,
								},
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
						onClick={onClose}
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
						Create Lab
					</Button>
				</Box>
			</form>
		</Dialog>
	);
};

export default CreateLabModal;
