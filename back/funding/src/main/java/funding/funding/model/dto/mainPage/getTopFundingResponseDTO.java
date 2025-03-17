package funding.funding.model.dto.mainPage;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class getTopFundingResponseDTO {

    private int funding_id;
    private String title;
    private String description;
    private LocalDateTime endDate;
    private int currentAmount;
    private int rate;
}
